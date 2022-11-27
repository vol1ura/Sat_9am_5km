# Pin npm packages by running ./bin/importmap
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true

pin "application", preload: true
pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "popper", to: "popper.js", preload: true

pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/charts", under: "charts"

pin "apexcharts", to: "https://ga.jspm.io/npm:apexcharts@3.35.4/dist/apexcharts.common.js"
