---
layout: page
title: Academics
permalink: /academics/
description: Qualifications, competitions and subject attainment.
nav: true
nav_order: 1
---

{% assign sections = "qualifications,competitions,subject_attainment" | split: "," %}
{% assign headings = "Qualifications,Competitions,Subject attainment" | split: "," %}

{% for key in sections %}
{% assign entries = site.data.academics[key] %}
{% if entries and entries.size > 0 %}

  <section class="entry-group" id="{{ key }}">
    <h2 class="entry-group-title">{{ headings[forloop.index0] }}</h2>
    <ul class="entry-list">
      {% comment %}Order follows the file, newest first. Liquid sort is unstable, so sorting here reshuffles same-year entries.{% endcomment %}{% assign sorted = entries %}
      {% for e in sorted %}
      <li class="entry">
        <div class="entry-year">{{ e.year }}</div>
        <div class="entry-body">
          <h3 class="entry-title">{{ e.title }}</h3>
          {% if e.score %}<div class="entry-meta">{{ e.score }}</div>{% endif %}
          {% if e.result %}<div class="entry-meta">{{ e.result }}{% if e.scope %} · {{ e.scope }}{% endif %}</div>{% endif %}
          {% if e.issuer %}<div class="entry-meta">{{ e.issuer }}</div>{% endif %}
          {% if e.detail %}<p class="entry-detail">{{ e.detail }}</p>{% endif %}
          {% if e.subjects and e.subjects.size > 0 %}
          <ul class="subject-list">
            {% for s in e.subjects %}
            <li class="subject"><span class="subject-name">{{ s.name }}</span><span class="subject-grade">{{ s.grade }}</span></li>
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
