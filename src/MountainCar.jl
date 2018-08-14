# Mountain Car problem for continuous reinforcement learning
# As described in XXX

mutable struct MountainCar <: MDP{Tuple{Float64,Float64},Float64}
  discount::Float64
  cost::Float64 # reward at each state not at the goal (should be a negative number)
  jackpot::Float64 # reward at the top
end
MountainCar(;discount::Float64=0.99,cost::Float64=-1., jackpot::Float64=100.0) = MountainCar(discount,cost,jackpot)

actions(::MountainCar) = [-1., 0., 1.]
n_actions(mc::MountainCar) = 3

reward(mc::MountainCar,
              s::Tuple{Float64,Float64},
              a::Float64,
              sp::Tuple{Float64,Float64}) = isterminal(mc,sp) ? mc.jackpot : mc.cost
              #sp::Tuple{Float64,Float64}) = isterminal(mc,sp) ? mc.jackpot : -norm(s[1]-0.5) 

function initial_state(mc::MountainCar, ::AbstractRNG)
  sp = (-0.5,0.,)
  return sp
end

isterminal(::MountainCar,s::Tuple{Float64,Float64}) = s[1] >= 0.5
discount(mc::MountainCar) = mc.discount

function generate_s( mc::MountainCar,
                     s::Tuple{Float64,Float64},
                     a::Float64,
                     ::AbstractRNG)
  x,v = s
  v_ = v + a*0.001+cos(3*x)*-0.0025
  v_ = max(min(0.07,v_),-0.07)
  x_ = x+v_
  #inelastic boundary
  if x_ < -1.2
      x_ = -1.2
      v_ = 0.
  end
  sp = (x_,v_,)
  return sp
end


function convert_s(::Type{A}, s::Tuple{Float64,Float64}, mc::MountainCar) where A<:AbstractArray
    v = copy!(A(2), s)
    return v
end
convert_s(::Type{Tuple{Float64,Float64}}, s::A, mc::MountainCar) where A<:AbstractArray = (s[1], s[2])

# Example policy -- works pretty well
mutable struct Energize <: Policy end
action(::Energize,s::Tuple{Float64,Float64}) = sign(s[2])
