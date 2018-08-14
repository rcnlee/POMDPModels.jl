# Inverted Pendulum task for continous reinforcement learning as describe in XXX

mutable struct InvertedPendulum <: MDP{Tuple{Float64,Float64},Float64}
    g::Float64
    m::Float64
    l::Float64
    M::Float64
    alpha::Float64
    dt::Float64
    discount::Float64
    cost::Float64
    # TODO add symbol for which integrator
    function InvertedPendulum(;
                              g::Float64=9.81,
                              m::Float64=2.,
                              M::Float64=8.,
                              l::Float64=0.5,
                              dt::Float64=0.1,
                              discount::Float64=0.99,
                              cost::Float64=-1.)
        self = new()
        self.g = g
        self.m = m
        self.l = l
        self.M = M
        self.m = m
        self.alpha = 1/(m+M)
        self.dt = dt
        self.discount = discount
        self.cost = cost
        return self
    end
end

actions(ip::InvertedPendulum) = [-50., 0., 50.]
n_actions(ip::InvertedPendulum) = 3

function initial_state(ip::InvertedPendulum, rng::AbstractRNG)
  sp = ((rand(rng)-0.5)*0.1, (rand(rng)-0.5)*0.1, )
  return sp
end

function reward(ip::InvertedPendulum,
              s::Tuple{Float64,Float64},
              a::Float64,
              sp::Tuple{Float64,Float64})
    #return isterminal(ip, sp) ? ip.cost : 0.0
    return isterminal(ip, sp) ? ip.cost : 0.1
    #return isterminal(ip, sp) ? ip.cost : -norm(sp[1]) 
end

discount(ip::InvertedPendulum) = ip.discount
isterminal(::InvertedPendulum, s::Tuple{Float64,Float64}) = abs(s[1]) > pi/2.

function dwdt(m::InvertedPendulum,th::Float64,w::Float64,u::Float64)
    num = m.g*sin(th)-m.alpha*m.m*m.l*(w^2)*sin(2*th)*0.5 - m.alpha*cos(th)*u
    den = (4/3)*m.l - m.alpha*m.l*(cos(th)^2)
    return num/den
end

# TODO
function rk45(m::InvertedPendulum,s::Tuple{Float64,Float64},a::Float64)
    k1 = dwdt(m,s[1],s[2],a)
    #something...
end

function euler(m::InvertedPendulum,s::Tuple{Float64,Float64},a::Float64)
    alph = dwdt(m,s[1],s[2],a)
    w_ = s[2] + alph*m.dt
    th_ = s[1] + s[2]*m.dt + 0.5*alph*m.dt^2
    if th_ > pi
        th_ -= 2*pi
    elseif th_ < -pi
        th_ += 2*pi
    end
    return (th_,w_)
end

function generate_s( ip::InvertedPendulum,
                    s::Tuple{Float64,Float64},
                    a::Float64,
                    rng::AbstractRNG)
  a_offset = 20*(rand(rng)-0.5)
  a_ = a + a_offset

  sp = euler(ip, s, a_)
  return sp
end

function convert_s(::Type{A}, s::Tuple{Float64,Float64}, ip::InvertedPendulum) where A<:AbstractArray
    v = copy!(Array{Float64}(2), s)
    return v
end

function convert_s(::Type{Tuple{Float64,Float64}}, s::A, ip::InvertedPendulum) where A<:AbstractArray
    return (s[1], s[2])
end
