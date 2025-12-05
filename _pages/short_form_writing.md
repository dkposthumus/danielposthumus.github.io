---
layout: single
title: "Short-Form Writing"
permalink: /short_writing/
author_profile: true
classes: wide
---

{% include base_path %}

{% if author.googlescholar %}
<p>You can also find my articles on <u><a href="{{ author.googlescholar }}" target="_blank" rel="noopener">my Google Scholar profile</a></u>.</p>
{% endif %}

{% assign me = site.author.name | default: "Daniel Posthumus" %}
{% capture me_bold %}<strong>{{ me }}</strong>{% endcapture %}

## Policy Writing

{% assign policy = site.short_writings | where: "pub_type", "policy" | sort: "order" %}
{% for pub in policy %}
<p class="pub-item">
  {% if pub.authors %}
    {% assign authors_str = pub.authors | join: ", " | replace: me, me_bold %}
    {{ authors_str }}.
  {% endif %}
  <a href="{{ pub.link | default: pub.paperurl }}" target="_blank" rel="noopener">{{ pub.title }}</a>{% if pub.venue %}. <em>{{ pub.venue }}</em>{% endif %}{% if pub.date %}, {{ pub.date | date: "%B %Y" }}{% endif %}.
</p>
{% endfor %}


## Public Writing

{% assign public = site.short_writings | where: "pub_type", "public" | sort: "order" %}
{% for pub in public %}
<p class="pub-item">
  {% if pub.authors %}
    {% assign authors_str = pub.authors | join: ", " | replace: me, me_bold %}
    {{ authors_str }}.
  {% endif %}
  <a href="{{ pub.link | default: pub.paperurl }}" target="_blank" rel="noopener">{{ pub.title }}</a>{% if pub.venue %}. <em>{{ pub.venue }}</em>{% endif %}{% if pub.date %}, {{ pub.date | date: "%B %Y" }}{% endif %}.
</p>
{% endfor %}