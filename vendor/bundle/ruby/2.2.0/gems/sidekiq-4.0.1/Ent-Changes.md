Sidekiq Enterprise Changelog
=======================

Please see [http://sidekiq.org/](http://sidekiq.org/) for more details and how to buy.

1.0.0.pre1
----------

- Enterprise 1.x targets Sidekiq 4.x.
- Rewrite several features to remove Celluloid dependency.  No
  functional changes.

0.7.8
----------

- Fix `unique_for: false` [#2658]


0.7.7
----------

- Enterprise 0.x targets Sidekiq 3.x.
- Fix racy shutdown event which could lead to disappearing periodic
  jobs, requires Sidekiq >= 3.5.3.
- Add new :leader event which is fired when a process gains leadership.

0.7.6
----------

- Redesign how overrated jobs are rescheduled to avoid creating new
  jobs. [#2619]

0.7.5
----------

- Fix dynamic creation of concurrent limiters [#2617]

0.7.4
----------
- Add additional check to prevent duplicate periodic job creation
- Allow user-specified TTLs for rate limiters [#2607]
- Paginate rate limiter index page [#2606]

0.7.3
----------

- Rework `Sidekiq::Limiter` redis handling to match global redis handling.
- Allow user to customize rate limit backoff logic and handle custom
  rate limit errors.
- Fix scalability issue with Limiter index page.

0.7.2
----------

- Fix typo which prevented limiters with '0' in their names.

0.7.1
----------

- Fix issue where unique scheduled jobs can't be enqueued upon schedule
  due to the existing unique lock. [#2499]

0.7.0
----------

Initial release.
