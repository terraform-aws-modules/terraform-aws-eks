import logging
import time

from kubernetes.client.rest import ApiException

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

MIRROR_POD_ANNOTATION_KEY = "kubernetes.io/config.mirror"
CONTROLLER_KIND_DAEMON_SET = "DaemonSet"


def cordon_node(api, node_name):
    """Marks the specified node as unschedulable, which means that no new pods can be launched on the
    node by the Kubernetes scheduler.
    """
    patch_body = {
        'apiVersion': 'v1',
        'kind': 'Node',
        'metadata': {
            'name': node_name
        },
        'spec': {
            'unschedulable': True
        }
    }

    api.patch_node(node_name, patch_body)


def remove_all_pods(api, node_name, poll=5):
    """Removes all Kubernetes pods from the specified node."""
    pods = get_evictable_pods(api, node_name)

    logger.debug('Number of pods to delete: ' + str(len(pods)))

    evict_until_completed(api, pods, poll)
    wait_until_empty(api, node_name, poll)


def pod_is_evictable(pod):
    if pod.metadata.annotations is not None and pod.metadata.annotations.get(MIRROR_POD_ANNOTATION_KEY):
        logger.info("Skipping mirror pod {}/{}".format(pod.metadata.namespace, pod.metadata.name))
        return False
    if pod.metadata.owner_references is None:
        return True
    for ref in pod.metadata.owner_references:
        if ref.controller is not None and ref.controller:
            if ref.kind == CONTROLLER_KIND_DAEMON_SET:
                logger.info("Skipping DaemonSet {}/{}".format(pod.metadata.namespace, pod.metadata.name))
                return False
    return True


def get_evictable_pods(api, node_name):
    field_selector = 'spec.nodeName=' + node_name
    pods = api.list_pod_for_all_namespaces(watch=False, field_selector=field_selector, include_uninitialized=True)
    return [pod for pod in pods.items if pod_is_evictable(pod)]


def evict_until_completed(api, pods, poll):
    pending = pods
    while True:
        pending = evict_pods(api, pending)
        if (len(pending)) <= 0:
            return
        time.sleep(poll)


def evict_pods(api, pods):
    remaining = []
    for pod in pods:
        logger.info('Evicting pod {} in namespace {}'.format(pod.metadata.name, pod.metadata.namespace))
        body = {
            'apiVersion': 'policy/v1beta1',
            'kind': 'Eviction',
            'deleteOptions': {},
            'metadata': {
                'name': pod.metadata.name,
                'namespace': pod.metadata.namespace
            }
        }
        try:
            api.create_namespaced_pod_eviction(pod.metadata.name, pod.metadata.namespace, body)
        except ApiException as err:
            if err.status == 429:
                remaining.append(pod)
                logger.warning("Pod {}/{} could not be evicted due to disruption budget. Will retry.".format(pod.metadata.namespace, pod.metadata.name))
            else:
                logger.exception("Unexpected error adding eviction for pod {}/{}".format(pod.metadata.namespace, pod.metadata.name))
        except:
            logger.exception("Unexpected error adding eviction for pod {}/{}".format(pod.metadata.namespace, pod.metadata.name))
    return remaining


def wait_until_empty(api, node_name, poll):
    logger.info("Waiting for evictions to complete")
    while True:
        pods = get_evictable_pods(api, node_name)
        if len(pods) <= 0:
            logger.info("All pods evicted successfully")
            return
        logger.debug("Still waiting for deletion of the following pods: {}".format(", ".join(map(lambda pod: pod.metadata.namespace + "/" + pod.metadata.name, pods))))
        time.sleep(poll)


def node_exists(api, node_name):
    """Determines whether the specified node is still part of the cluster."""
    nodes = api.list_node(include_uninitialized=True, pretty=True).items
    node = next((n for n in nodes if n.metadata.name == node_name), None)
    return False if not node else True


def abandon_lifecycle_action(asg_client, auto_scaling_group_name, lifecycle_hook_name, instance_id):
    """Completes the lifecycle action with the ABANDON result, which stops any remaining actions,
    such as other lifecycle hooks.
    """
    asg_client.complete_lifecycle_action(LifecycleHookName=lifecycle_hook_name,
                                         AutoScalingGroupName=auto_scaling_group_name,
                                         LifecycleActionResult='ABANDON',
                                         InstanceId=instance_id)
