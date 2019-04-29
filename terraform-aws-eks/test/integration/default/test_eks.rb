# frozen_string_literal: true

require 'awspec'

# rubocop:disable LineLength
state_file = 'terraform.tfstate.d/kitchen-terraform-default-aws/terraform.tfstate'
tf_state = JSON.parse(File.open(state_file).read)
region = tf_state['modules'][0]['outputs']['region']['value']
ENV['AWS_REGION'] = region
