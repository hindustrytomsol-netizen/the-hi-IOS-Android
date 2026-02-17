## Migration Roadmap

This document outlines the high-level approach for migrating the-hi from its existing Next.js-based native apps to Flutter.

### Strategy

- **Strategy A – Parallel product**  
  Build the Flutter app alongside the existing stack, allowing gradual rollout, A/B testing, and controlled feature parity.

- **Strategy B – Vertical slices**  
  Migrate end-to-end user journeys as vertical slices (from UI to backend integration) rather than isolated widgets, to keep each slice shippable and testable.

Both strategies are used together: we develop a parallel Flutter product, delivered in vertical slices.

### Priority order

1. **Auth / Profile + App foundation**
2. **Shell + Design system**
3. **Chat (10 stages parity)**
4. **Media module**
5. **Feed**
6. **Push notifications**

### Checklist

| Stage                              | Status        | Notes |
|------------------------------------|--------------|-------|
| Auth / Profile + App foundation    | Not started  |       |
| Shell + Design system              | Not started  |       |
| Chat (10 stages parity)            | Not started  |       |
| Media module                       | Not started  |       |
| Feed                               | Not started  |       |
| Push notifications                 | Not started  |       |

