---
layout: about
title: About
permalink: /
subtitle: AI researcher · Embodied intelligence · Generative models

profile:
  align: right
  image: chengjie-lu.png
  image_circular: true # crops the image to make it circular
  more_info: >
    <p class="profile-role"><strong>Joint PhD Student</strong></p>
    <p>ShanghaiTech × BIGAI</p>
    <p>Shanghai &amp; Beijing, China</p>

selected_papers: false
social: true # includes social icons at the bottom of the page

announcements:
  enabled: false

latest_posts:
  enabled: false
---

I am **Chengjie Lu**, an AI researcher interested in building intelligent systems that can understand, predict, and interact with the physical world. My current research focuses on **Embodied AI** and **World Models**.

My research spans human motion prediction and efficient diffusion models, with a current focus on embodied AI and world models. Previously, I studied behavior-aware representations for 3D human motion prediction and training-free acceleration methods for diffusion transformers.

## Research Interests

<div class="research-focus">
  <span>Embodied AI</span>
  <span>World Models</span>
  <span>Diffusion Model Acceleration</span>
  <span>Human Motion Prediction</span>
</div>

<section class="recent-publications">
  <h2>Recent Publications</h2>
  <div class="publications">
    {% bibliography --group_by none --query @*[selected=true]* %}
  </div>
  <a class="more-publications" href="{{ '/publications/' | relative_url }}">More Publications →</a>
</section>
