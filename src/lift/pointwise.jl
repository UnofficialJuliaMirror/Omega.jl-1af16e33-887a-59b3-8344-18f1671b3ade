Cassette.@context PwCtx

# Cassette.execute(::SinCtx, ::Typ(sin), x) = cos(x)
Cassette.execute(::PwCtx, op, f, g) = Omega.mkrv(op, (f, g))
Cassette.execute(::PwCtx, op, f) = Omega.mkrv(op, (f,))

# Cassette.@primitive tuple(f::RandVar) where {__CONTEXT__ <: PwCtx} =
#   Omega.mkrv(tuple, (f,))

# Cassette.@primitive (op::Any)(x::RandVar) where {__CONTEXT__ <: PwCtx} =
#   Omega.mkrv(op, (x,))

"""Do `thunk` with pointwise style

```
julia> jump(x::Real, y::Real) = x + y
jump (generic function with 1 method)

julia> x = normal(0.0, 1.0)
Omega.normal(0.0, 1.0)::Float64

julia> q = Omega.pw() do
  jump(x, x)
end
jump(Omega.normal, Omega.normal)::Float64

julia> rand(q)
1.2107319112950392
```
"""
function pw(thunk)
  Cassette.overdub(PwCtx(), thunk)
end

