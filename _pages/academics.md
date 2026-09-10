---
layout: page
title: academics
permalink: /academics/
description: Awards, competitions and academic attainments.
nav: true
nav_order: 1
---

{% assign sections = "awards,competitions,attainments" | split: "," %}
{% assign headings = "Awards,Competitions,Academic attainments" | split: "," %}

{% for key in sections %}
{% assign entries = site.data.academics[key] %}
{% if entries and entries.size > 0 %}

  <section class="entry-group" id="{{ key }}">
    <h2 class="entry-group-title">{{ headings[forloop.index0] }}</h2>
    <ul class="entry-list">
      {% assign sorted = entries | sort: "year" | reverse %}
      {% for e in sorted %}
      <li class="entry">
        <div class="entry-year">{{ e.year }}</div>
        <div class="entry-body">
          <h3 class="entry-title">{{ e.title }}</h3>
          {% if e.issuer %}<div class="entry-meta">{{ e.issuer }}</div>{% endif %}
          {% if e.result %}<div class="entry-meta">{{ e.result }}{% if e.scope %} · {{ e.scope }}{% endif %}</div>{% endif %}
          {% if e.score %}<div class="entry-meta">{{ e.score }}</div>{% endif %}
          {% if e.detail %}<p class="entry-detail">{{ e.detail }}</p>{% endif %}
        </div>
      </li>
      {% endfor %}
    </ul>
  </section>
  {% endif %}
{% endfor %}
