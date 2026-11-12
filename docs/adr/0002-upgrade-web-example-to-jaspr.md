# Web Example Migration to Jaspr Client Island

We migrated the web demonstration app in `example/` from the deprecated AngularDart framework to a hybrid static HTML article with an interactive Jaspr client island and standard web interop.

The explanatory article prose, meta tags, and imagery are preserved as pure static HTML in `web/index.html` for optimal SEO and instant initial paint, while the interactive calculator is mounted as a client island into `#calculator`. Heavy Monte Carlo simulations (250,000 iterations for **Stochastic Formulas**) remain offloaded to a dedicated Web Worker using modern `package:web` message channels, ensuring 60fps UI responsiveness during intensive computations without deprecated package dependencies.

## Considered Options

- **Full-page Jaspr Static Generation / SSR**: Generates all HTML via server/static entrypoints, but breaks standard Dart `build_runner serve` workflows and couples static article prose to Dart component hierarchies.
- **Full-page Client-rendered Jaspr**: Renders both article prose and calculator via client-side JavaScript, which degrades SEO and delays initial text rendering.
- **Client Island with Static HTML (Selected)**: Preserves the entire article text, metadata, and styles as static HTML in `web/index.html` for search engines and fast rendering, mounting Jaspr exclusively into the `#calculator` island container with a dedicated Web Worker for simulation workloads.
