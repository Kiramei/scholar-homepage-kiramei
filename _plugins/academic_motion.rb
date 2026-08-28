# frozen_string_literal: true

module AcademicExperience
  LOADER_STYLE = <<~HTML.freeze
    <style id="academic-loader-critical">
      #academic-loader {
        position: fixed;
        inset: 0;
        z-index: 2147483000;
        display: grid;
        place-items: center;
        background: var(--global-bg-color, #fff);
        color: var(--global-text-color, #151515);
        opacity: 0;
        visibility: hidden;
        pointer-events: none;
        transition: opacity 200ms cubic-bezier(0.22, 0.61, 0.36, 1), visibility 0s linear 200ms;
      }

      #academic-loader.is-visible {
        opacity: 1;
        visibility: visible;
        pointer-events: auto;
        transition-delay: 0s;
      }

      #academic-loader.is-leaving {
        opacity: 0;
        pointer-events: none;
      }

      .academic-loader-inner {
        display: grid;
        justify-items: center;
        width: min(82vw, 28rem);
        text-align: center;
      }

      .academic-loader-mark {
        width: 4.75rem;
        height: 4.75rem;
        margin-bottom: 1.15rem;
        border-radius: 50%;
        box-shadow: 0 0.6rem 2rem rgb(0 0 0 / 9%);
        animation: academic-loader-float 1.8s ease-in-out infinite;
      }

      .academic-loader-title {
        margin: 0;
        font-family: "TeX Gyre Pagella", "Pagella Fallback", Georgia, serif;
        font-size: clamp(1.75rem, 5vw, 2.45rem);
        font-variant-caps: small-caps;
        font-weight: 700;
        letter-spacing: 0.055em;
        line-height: 1;
      }

      .academic-loader-context {
        margin: 0.8rem 0 0;
        font-family: "Maple Mono", "SFMono-Regular", Consolas, monospace;
        font-size: 0.68rem;
        letter-spacing: 0.13em;
        line-height: 1.5;
        text-transform: uppercase;
        opacity: 0.72;
      }

      .academic-loader-rule {
        position: relative;
        width: 7.5rem;
        height: 1px;
        margin-top: 1.1rem;
        overflow: hidden;
        background: rgb(128 128 128 / 24%);
      }

      .academic-loader-rule::after {
        position: absolute;
        inset: 0;
        background: var(--global-theme-color, #b509ac);
        content: "";
        transform: translateX(-105%);
        animation: academic-loader-sweep 1.15s cubic-bezier(0.65, 0, 0.35, 1) infinite;
      }

      @keyframes academic-loader-float {
        0%, 100% { transform: translateY(0); }
        50% { transform: translateY(-0.3rem); }
      }

      @keyframes academic-loader-sweep {
        0% { transform: translateX(-105%); }
        55%, 100% { transform: translateX(105%); }
      }

      @media (prefers-color-scheme: dark) {
        html:not([data-theme="light"]) #academic-loader {
          background: var(--global-bg-color, #1c1c1d);
          color: var(--global-text-color, #e8e8e8);
        }

        html:not([data-theme="light"]) .academic-loader-rule::after {
          background: var(--global-theme-color, #2698ba);
        }
      }

      @media (prefers-reduced-motion: reduce) {
        #academic-loader,
        .academic-loader-mark,
        .academic-loader-rule::after {
          animation: none !important;
          transition-duration: 1ms !important;
        }
      }
    </style>
  HTML

  def self.preloads(baseurl, homepage)
    links = [
      %(<link rel="preload" href="#{baseurl}/assets/fonts/texgyrepagella-regular.woff2" as="font" type="font/woff2" crossorigin>),
      %(<link rel="preload" href="#{baseurl}/assets/fonts/texgyrepagella-bold.woff2" as="font" type="font/woff2" crossorigin>),
      %(<link rel="preload" href="#{baseurl}/assets/img/favicon.png" as="image">)
    ]
    links << %(<link rel="preload" href="#{baseurl}/assets/img/chengjie-lu.png" as="image">) if homepage
    links.join("\n")
  end

  def self.loader(baseurl)
    <<~HTML
      <div id="academic-loader" role="status" aria-live="polite" aria-label="Loading Chengjie Lu's academic homepage">
        <div class="academic-loader-inner">
          <img class="academic-loader-mark" src="#{baseurl}/assets/img/favicon.png" width="76" height="76" alt="">
          <p class="academic-loader-title">Chengjie Lu</p>
          <p class="academic-loader-context">Research · Publications · Code</p>
          <span class="academic-loader-rule" aria-hidden="true"></span>
        </div>
      </div>
      <script id="academic-loader-delay">
        (() => {
          const loader = document.getElementById("academic-loader");
          if (!loader) return;

          const storageKey = "academic-loader-seen";
          let alreadySeen = false;
          try { alreadySeen = sessionStorage.getItem(storageKey) === "1"; } catch (_) {}
          if (alreadySeen) {
            loader.remove();
            return;
          }

          let shownAt = 0;
          let finishing = false;
          const showTimer = window.setTimeout(() => {
            if (finishing) return;
            shownAt = performance.now();
            loader.classList.add("is-visible");
            try { sessionStorage.setItem(storageKey, "1"); } catch (_) {}
          }, 120);

          const finish = () => {
            if (finishing) return;
            finishing = true;
            window.clearTimeout(showTimer);
            const minimumVisible = shownAt ? Math.max(0, 180 - (performance.now() - shownAt)) : 0;
            window.setTimeout(() => {
              if (!shownAt) {
                loader.remove();
                return;
              }
              loader.classList.add("is-leaving");
              window.setTimeout(() => loader.remove(), 220);
            }, minimumVisible);
          };

          const settle = () => {
            const fontsReady = document.fonts
              ? Promise.all([
                  document.fonts.load('400 1rem "TeX Gyre Pagella"'),
                  document.fonts.load('700 1rem "TeX Gyre Pagella"')
                ])
              : Promise.resolve();
            Promise.race([
              fontsReady,
              new Promise((resolve) => window.setTimeout(resolve, 180))
            ]).then(finish, finish);
          };

          if (document.readyState === "loading") {
            document.addEventListener("DOMContentLoaded", settle, { once: true });
          } else {
            settle();
          }
          window.setTimeout(finish, 1800);
        })();
      </script>
    HTML
  end
end

Jekyll::Hooks.register %i[pages documents], :post_render do |document|
  next unless document.output_ext == ".html" && document.output.include?("</head>") && document.output.include?("</body>")

  baseurl = document.site.config["baseurl"].to_s.sub(%r{/$}, "")
  head_assets = [AcademicExperience.preloads(baseurl, document.url == "/"), AcademicExperience::LOADER_STYLE].join("\n")
  document.output = document.output.sub("</head>", "#{head_assets}\n</head>")
  document.output = document.output.sub(/(<body\b[^>]*>)/) { |body| "#{body}\n#{AcademicExperience.loader(baseurl)}" }
  motion = %(<script defer src="#{baseurl}/assets/js/academic-motion.js"></script>)
  document.output = document.output.sub("</body>", "#{motion}\n</body>")
end
