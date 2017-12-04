module RLS
  # Gaming platform that is tracked by RLS. These are changed very infrequently,
  # so this constant enum is provided to avoid unecessary API requests.
  # TODO: The `Switch` value is not verified / implemented yet in RLS
  enum Platform : UInt8
    Steam   = 1
    Ps4     = 2
    XboxOne = 3
    Switch  = 4
  end
end
