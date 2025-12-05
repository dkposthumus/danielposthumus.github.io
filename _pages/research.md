---
layout: single
title: "Research"
permalink: /research/
author_profile: true
classes: wide
---

{% include base_path %}

{% if author.googlescholar %}
<p>You can also find my work on <a href="{{ author.googlescholar }}" target="_blank" rel="noopener"><u>my Google Scholar profile</u></a>.</p>
{% endif %}

<style>
  .pub-item { margin: 0 0 1.1rem 0; }
  .pub-cite { line-height: 1.45; }
  .pub-links a { margin-right: .6rem; }
  details.pub-abstract { margin-top: .35rem; }
  details.pub-abstract > summary { cursor: pointer; }
  .pub-abstract-body { margin-top: .35rem; }
</style>

{% assign me = site.author.name | default: "Daniel Posthumus" %}
{% capture me_bold %}<strong>{{ me }}</strong>{% endcapture %}

{% comment %}
  Helper convention:
  - Put structured metadata in front matter (authors, title, venue, date, links).
  - Put the abstract either in `abstract:` OR in the Markdown body of the pub file.
{% endcomment %}

## Peer-Reviewed Publications

{% assign peer = site.research | where: "pub_type", "peer_reviewed" | sort: "order" %}
{% for pub in peer %}
<div class="pub-item">
  <div class="pub-cite">
    {% if pub.authors %}
      {% assign authors_str = pub.authors | join: ", " | replace: me, me_bold %}
      {{ authors_str }}.
    {% endif %}
    <a href="{{ pub.link | default: pub.paperurl }}" target="_blank" rel="noopener">{{ pub.title }}</a>{% if pub.venue %}. <em>{{ pub.venue }}</em>{% endif %}{% if pub.date %}, {{ pub.date | date: "%B %Y" }}{% endif %}.
    {% if pub.links %}
      <span class="pub-links">
        {% for l in pub.links %}
          <a href="{{ l.url }}" target="_blank" rel="noopener">{{ l.label }}</a>
        {% endfor %}
      </span>
    {% endif %}
  </div>

  {% assign abstract_text = pub.abstract %}
  {% if abstract_text == nil or abstract_text == "" %}
    {% assign abstract_text = pub.content | strip %}
  {% endif %}
  {% if abstract_text != "" %}
    <details class="pub-abstract">
      <summary>Abstract</summary>
      <div class="pub-abstract-body">
        {{ abstract_text | markdownify }}
      </div>
    </details>
  {% endif %}
</div>
{% endfor %}

{% assign wp = site.research | where: "pub_type", "working_paper" | sort: "order" %}
{% if wp and wp.size > 0 %}
## Working Papers and Works-in-Progress

{% for pub in wp %}
<div class="pub-item">
  <div class="pub-cite">
    {% if pub.authors %}
      {% assign authors_str = pub.authors | join: ", " | replace: me, me_bold %}
      {{ authors_str }}.
    {% endif %}
    <a href="{{ pub.link | default: pub.paperurl }}" target="_blank" rel="noopener">{{ pub.title }}</a>{% if pub.venue %}. <em>{{ pub.venue }}</em>{% endif %}{% if pub.date %}, {{ pub.date | date: "%B %Y" }}{% endif %}.
    {% if pub.links %}
      <span class="pub-links">
        {% for l in pub.links %}
          <a href="{{ l.url }}" target="_blank" rel="noopener">{{ l.label }}</a>
        {% endfor %}
      </span>
    {% endif %}
  </div>

  {% assign abstract_text = pub.abstract %}
  {% if abstract_text == nil or abstract_text == "" %}
    {% assign abstract_text = pub.content | strip %}
  {% endif %}
  {% if abstract_text != "" %}
    <details class="pub-abstract">
      <summary>Abstract</summary>
      <div class="pub-abstract-body">
        {{ abstract_text | markdownify }}
      </div>
    </details>
  {% endif %}
</div>
{% endfor %}
{% endif %}