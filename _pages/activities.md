---
layout: page
title: activities
permalink: /activities/
description: Sport, performing arts, languages and leadership.
nav: true
nav_order: 4
---

{% for block in site.data.activities %}
{% if block.items and block.items.size > 0 %}

  <section class="entry-group" id="{{ block.section | slugify }}">
    <h2 class="entry-group-title">
      {% if block.icon %}<i class="{{ block.icon }}" aria-hidden="true"></i> {% endif %}{{ block.section }}
    </h2>
    <ul class="entry-list">
      {% for e in block.items %}
      <li class="entry">
        <div class="entry-year">{{ e.year }}</div>
        <div class="entry-body">
          <h3 class="entry-title">{{ e.title }}</h3>
          {% if e.detail %}<p class="entry-detail">{{ e.detail }}</p>{% endif %}
        </div>
      </li>
      {% endfor %}
    </ul>
  </section>
  {% endif %}
{% endfor %}
