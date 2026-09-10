---
layout: page
title: Research & Learning
permalink: /research/
description: Research work, courses and independent study.
nav: true
nav_order: 2
---

{% assign sections = "research,courses,independent_study" | split: "," %}
{% assign headings = "Research,Courses,Independent study" | split: "," %}

{% for key in sections %}
{% assign entries = site.data.research[key] %}
{% if entries and entries.size > 0 %}

  <section class="entry-group" id="{{ key }}">
    <h2 class="entry-group-title">{{ headings[forloop.index0] }}</h2>
    <ul class="entry-list">
      {% assign sorted = entries | sort: "year" | reverse %}
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
          {% if e.detail %}<p class="entry-detail">{{ e.detail }}</p>{% endif %}
        </div>
      </li>
      {% endfor %}
    </ul>
  </section>
  {% endif %}
{% endfor %}
