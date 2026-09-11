---
layout: page
title: Research & Learning
permalink: /research/
description: Research work and courses.
nav: true
nav_order: 2
---

{% assign sections = "research,courses" | split: "," %}
{% assign headings = "Research,Courses" | split: "," %}

{% for key in sections %}
{% assign entries = site.data.research[key] %}
{% if entries and entries.size > 0 %}

  <section class="entry-group" id="{{ key }}">
    <h2 class="entry-group-title">{{ headings[forloop.index0] }}</h2>
    <ul class="entry-list">
      {% comment %}Order follows the file, newest first. Liquid sort is unstable, so sorting here reshuffles same-year entries.{% endcomment %}{% assign sorted = entries %}
      {% for e in sorted %}
      <li class="entry">
        <div class="entry-year">{{ e.year }}</div>
        <div class="entry-body">
          <h3 class="entry-title">
            {% if e.url %}<a href="{{ e.url }}">{{ e.title }}</a>{% else %}{{ e.title }}{% endif %}
          </h3>
          {% if e.role %}<div class="entry-meta">{{ e.role }}</div>{% endif %}
          {% if e.provider %}<div class="entry-meta">{{ e.provider }}</div>{% endif %}
          {% if e.venue %}<div class="entry-meta">{{ e.venue }}</div>{% endif %}
          {% if e.status %}<div class="entry-status">{{ e.status }}</div>{% endif %}
          {% if e.detail %}<p class="entry-detail">{{ e.detail }}</p>{% endif %}
          {% if e.topics and e.topics.size > 0 %}
          <ul class="topic-list">
            {% for t in e.topics %}
            <li class="topic">{{ t }}</li>
            {% endfor %}
          </ul>
          {% endif %}
        </div>
      </li>
      {% endfor %}
    </ul>
  </section>
  {% endif %}
{% endfor %}
