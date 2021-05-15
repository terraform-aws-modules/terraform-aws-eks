# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this
project adheres to [Semantic Versioning](http://semver.org/).

{{ if .Versions -}}
<a name="unreleased"></a>
## [Unreleased]
{{ if .Unreleased.CommitGroups -}}
{{ range .Unreleased.CommitGroups -}}
{{ .Title }}:
{{ range .Commits -}}
{{- if .Subject -}}
- {{ if .Scope }}**{{ .Scope }}:** {{ end }}{{ .Subject | upperFirst }}
{{ end -}}
{{ end }}
{{ end -}}
{{ else }}
{{ range .Unreleased.Commits -}}
{{- if .Subject -}}
- {{ if .Scope }}**{{ .Scope }}:** {{ end }}{{ .Subject | upperFirst}}
{{ end -}}
{{ end }}
{{ end -}}

{{- if .Unreleased.NoteGroups -}}
{{ range .Unreleased.NoteGroups -}}
{{ .Title }}:
{{ range .Notes -}}
- {{ .Body }}
{{ end }}
{{ end -}}
{{ end -}}
{{ end -}}

{{ range .Versions }}
<a name="{{ .Tag.Name }}"></a>
## {{ if .Tag.Previous }}[{{ .Tag.Name }}]{{ else }}{{ .Tag.Name }}{{ end }} - {{ datetime "2006-01-02" .Tag.Date }}
{{ if .CommitGroups -}}
{{ range .CommitGroups -}}
{{ .Title }}:
{{ range .Commits -}}
{{- if .Subject -}}
- {{ if .Scope }}**{{ .Scope }}:** {{ end }}{{ .Subject | upperFirst }}
{{ end -}}
{{ end }}
{{ end -}}
{{ else }}
{{ range .Commits -}}
{{- if .Subject -}}
- {{ if .Scope }}**{{ .Scope }}:** {{ end }}{{ .Subject | upperFirst }}
{{ end -}}
{{ end }}
{{ end -}}

{{- if .NoteGroups -}}
{{ range .NoteGroups -}}
{{ .Title }}:
{{ range .Notes -}}
- {{ .Body }}
{{ end }}
{{ end -}}
{{ end -}}
{{ end -}}

{{- if .Versions }}
[Unreleased]: {{ .Info.RepositoryURL }}/compare/{{ $latest := index .Versions 0 }}{{ $latest.Tag.Name }}...HEAD
{{ range .Versions -}}
{{ if .Tag.Previous -}}
[{{ .Tag.Name }}]: {{ $.Info.RepositoryURL }}/compare/{{ .Tag.Previous.Name }}...{{ .Tag.Name }}
{{ end -}}
{{ end -}}
{{ end -}}
