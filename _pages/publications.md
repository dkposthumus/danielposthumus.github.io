---
layout: single
title: "Publications"
permalink: /publications/
author_profile: true
classes: wide
---

{% include base_path %}

{% if author.googlescholar %}
<p>You can also find my articles on <u><a href="{{ author.googlescholar }}" target="_blank" rel="noopener">my Google Scholar profile</a></u>.</p>
{% endif %}

{% assign me = site.author.name | default: "Daniel Posthumus" %}
{% capture me_bold %}<strong>{{ me }}</strong>{% endcapture %}

## Peer-Reviewed Publications

{% assign peer = site.publications | where: "pub_type", "peer_reviewed" | sort: "order" %}
{% for pub in peer %}
- {%- if pub.authors -%}
  {%- assign authors_str = pub.authors | join: ", " | replace: me, me_bold -%}
  {{ authors_str }}. 
  {%- endif -%}
  <a href="{{ pub.link | default: pub.paperurl }}" target="_blank" rel="noopener">{{ pub.title }}</a>{% if pub.venue %}. <em>{{ pub.venue }}</em>{% endif %}{% if pub.date %}, {{ pub.date | date: "%B %Y" }}{% endif %}.
{% endfor %}

## Public Writing & Policy Briefs

{% assign policy = site.publications | where: "pub_type", "policy" | sort: "order" %}
{% for pub in policy %}
- {%- if pub.authors -%}
  {%- assign authors_str = pub.authors | join: ", " | replace: me, me_bold -%}
  {{ authors_str }}. 
  {%- endif -%}
  <a href="{{ pub.link | default: pub.paperurl }}" target="_blank" rel="noopener">{{ pub.title }}</a>{% if pub.venue %}. <em>{{ pub.venue }}</em>{% endif %}{% if pub.date %}, {{ pub.date | date: "%B %Y" }}{% endif %}.
{% endfor %}