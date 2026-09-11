---
layout: page
permalink: /cv/
title: CV
nav: true
nav_order: 6
description: Full curriculum vitae.
---

{% assign cv_file = "/assets/pdf/cv.pdf" %}

{% comment %}
Only render the download button and the embed if the file is actually there.
Without this the page ships a button and a PDF viewer both pointing at a 404.
Drop your CV at assets/pdf/cv.pdf and this page fills itself in.
{% endcomment %}
{% assign cv_exists = false %}
{% for f in site.static_files %}
{% if f.path == cv_file %}{% assign cv_exists = true %}{% break %}{% endif %}
{% endfor %}

{% if cv_exists %}

  <p class="cv-actions">
    <a class="btn btn-sm z-depth-0" href="{{ cv_file | relative_url }}" target="_blank" rel="noopener">
      <i class="fa-solid fa-download" aria-hidden="true"></i> Download PDF
    </a>
  </p>

  <object class="cv-embed" data="{{ cv_file | relative_url }}" type="application/pdf" width="100%" height="800">
    <p>
      Your browser cannot display PDFs inline.
      <a href="{{ cv_file | relative_url }}">Download the CV instead</a>.
    </p>
  </object>

{% else %}

  <p class="entry-detail">My CV is going up here shortly. In the meantime, <a href="/academics/">Academics</a>, <a href="/research/">Research &amp; Learning</a> and <a href="/activities/">Activities</a> cover the same ground.</p>

{% endif %}
