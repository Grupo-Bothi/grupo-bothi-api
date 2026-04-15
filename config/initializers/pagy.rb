require "pagy/extras/limit"

Pagy::DEFAULT[:limit]       = 20
Pagy::DEFAULT[:limit_param] = :page_size
Pagy::DEFAULT[:limit_max]   = 100
