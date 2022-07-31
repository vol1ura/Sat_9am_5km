# Pin npm packages by running ./bin/importmap
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true

pin "application", preload: true
pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "popper", to: "popper.js", preload: true

pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"

# pin "htm", to: "https://cdn.jsdelivr.net/npm/htm@3.1.1/dist/htm.module.js"
# pin_all_from "app/javascript/components", under: "components"

# pin "chartkick", to: "chartkick.js"
# pin "Chart.bundle", to: "Chart.bundle.js"

# pin "react", to: "https://ga.jspm.io/npm:react@18.2.0/index.js"
# pin "react-dom", to: "https://ga.jspm.io/npm:react-dom@18.2.0/index.js"
# pin "process", to: "https://ga.jspm.io/npm:@jspm/core@2.0.0-beta.24/nodelibs/browser/process-production.js"
# pin "scheduler", to: "https://ga.jspm.io/npm:scheduler@0.23.0/index.js"
