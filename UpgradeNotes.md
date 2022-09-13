# Upgrade Notes

## From version 0.7.1 and prior to version 0.8
##### The Definition::ValueObject was removed and replaced by Definition:Model
If you used ValueObjects then you need to migrate them to Models. This will be very easy if you used the ValueObject with a `Definition.Keys` definition, which is most likely the case.

Before:
```ruby
class User < Definition::ValueObject
  definition(Definition.Keys do
    required :username, Definition.Type(String)
    required :password, Definition.Type(String)
  end)
end
```

After:
```ruby
class User < Definition::Model
  required :username, Definition.Type(String)
  required :password, Definition.Type(String)
end
```

If you use the `Definition.CoercibleValueObject` definition in your models, you just need to replace those with a `Definition.CoercibleModel` definition.

If you use ValueObjects that do not use a `Keys` definition then there is currently no built in replacement available.