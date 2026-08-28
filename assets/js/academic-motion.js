(() => {
  const root = document.documentElement;
  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
  const finePointer = window.matchMedia("(pointer: fine)");

  const initializeRevealMotion = () => {
    if (reducedMotion.matches) {
      root.dataset.motion = "reduced";
      return;
    }

    root.dataset.motion = "active";
    const selectors = [
      ".post-header",
      ".profile",
      ".post article > .clearfix > p",
      ".research-focus",
      ".recent-publications",
      ".publications > h2",
      ".publications ol.bibliography > li",
      ".projects .card",
      ".cv .card",
    ];
    const targets = [...new Set(document.querySelectorAll(selectors.join(", ")))];

    targets.forEach((target, index) => {
      target.classList.add("motion-reveal");
      target.style.setProperty("--motion-delay", `${Math.min(index % 4, 3) * 70}ms`);
    });

    if (!("IntersectionObserver" in window)) {
      targets.forEach((target) => target.classList.add("motion-visible"));
      return;
    }

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (!entry.isIntersecting) {
            return;
          }
          entry.target.classList.add("motion-visible");
          observer.unobserve(entry.target);
        });
      },
      { threshold: 0.12, rootMargin: "0px 0px -6% 0px" }
    );

    requestAnimationFrame(() => {
      requestAnimationFrame(() => targets.forEach((target) => observer.observe(target)));
    });
  };

  const initializeInertialScroll = () => {
    if (reducedMotion.matches || !finePointer.matches || window.innerWidth < 768) {
      root.dataset.motionScroll = "native";
      return;
    }

    root.dataset.motionScroll = "inertial";
    let currentY = window.scrollY;
    let targetY = currentY;
    let frame = null;

    const maximumScroll = () => Math.max(0, document.documentElement.scrollHeight - window.innerHeight);
    const clamp = (value) => Math.min(maximumScroll(), Math.max(0, value));

    const glide = () => {
      const distance = targetY - currentY;
      if (Math.abs(distance) < 0.5) {
        currentY = targetY;
        window.scrollTo(0, currentY);
        frame = null;
        return;
      }

      currentY += distance * 0.12;
      window.scrollTo(0, currentY);
      frame = requestAnimationFrame(glide);
    };

    window.addEventListener(
      "wheel",
      (event) => {
        if (event.ctrlKey || event.metaKey || Math.abs(event.deltaX) > Math.abs(event.deltaY)) {
          return;
        }

        event.preventDefault();
        const scale = event.deltaMode === WheelEvent.DOM_DELTA_LINE ? 18 : event.deltaMode === WheelEvent.DOM_DELTA_PAGE ? window.innerHeight : 1;
        currentY = frame === null ? window.scrollY : currentY;
        targetY = clamp(targetY + event.deltaY * scale);
        if (frame === null) {
          frame = requestAnimationFrame(glide);
        }
      },
      { passive: false }
    );

    window.addEventListener(
      "scroll",
      () => {
        if (frame === null) {
          currentY = window.scrollY;
          targetY = currentY;
        }
      },
      { passive: true }
    );
  };

  const initialize = () => {
    initializeRevealMotion();
    initializeInertialScroll();
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initialize, { once: true });
  } else {
    initialize();
  }
})();
