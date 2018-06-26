#= This script defines the function in order to interpolate variables from
one grid (u,v,T,q) to another (u,v,T,q), due to the staggered Arakawa C-grid.

    The notation is Iab where a ∈ {u,v,T,q} and b ∈ {u,v,T,q}, with a being
    the departure grid and b the destination grid.

This interpolation is a 2-point averaging with coefficients (1/2,1/2) for

    ITu,ITv,IuT,IvT,Iqu,Iqv,Ivq,Iuq

and a 4-point averaging with coefficients (1/4,1/4,1/4,1/4) for

    ITq,IqT,Iuv,Ivu.

Each function takes the return variable as first argument and the variable to be
interpolated as second argument. =#

# ------------- 2-point interpolation between T and u or v. -----------------

function ITu_nonperiodic(u,T)
    #= Interpolates a variable T from the T-grid to a variable u on the u-grid. =#
    u[:,:] = one_half*(T[2:end,:] + T[1:end-1,:])
    return u
end

function ITu_periodic(u,T)
    #= Interpolates a variable T from the T-grid to a variable u on the u-grid. =#
    u[2:end,:] = one_half*(T[2:end,:] + T[1:end-1,:])
    u[1,:] = one_half*(T[1,:] + T[end,:])
    return u
end

function ITv(v,T)
    #= Interpolates a variable T from the T-grid to a variable v on the v-grid. =#
    v[:,:] = one_half*(T[:,2:end] + T[:,1:end-1])
    return v
end

function IuT_nonperiodic(T,u)
    #= Interpolates a variable u from the u-grid to a variable T on the T-grid. =#
    T[1,:] = one_half*u[1,:]    # +0, kinematic boundary condition
    T[2:end-1,:] = one_half*(u[2:end,:] + u[1:end-1,:])
    T[end,:] = one_half*u[end,:] # +0, kinematic bc
    return T
end

function IuT_periodic(T,u)
    #= Interpolates a variable u from the u-grid to a variable T on the T-grid. =#
    T[1:end-1,:] = one_half*(u[2:end,:] + u[1:end-1,:])
    T[end,:] = one_half*(u[1,:]+u[end,:])
    return T
end

function IvT(T,v)
    #= Interpolates a variable v from the v-grid to a variable T on the T-grid. =#
    T[:,2:end-1] = one_half*(v[:,2:end] + v[:,1:end-1])
    T[:,1] = one_half*v[:,1] # +0, kinematic bc
    T[:,end] = one_half*v[:,end] # +0, kinematic bc
    return T
end

# ------------- 2-point interpolation between q and u or v. -----------------

function Iqu_nonperiodic(u,q)
    #= Interpolates a variable q from the q-grid to a variable u on the u-grid. =#
    u[:,:] = one_half*(q[2:end-1,1:end-1] + q[2:end-1,2:end])
    return u
end

function Iqu_periodic(u,q)
    #= Interpolates a variable q from the q-grid to a variable u on the u-grid. =#
    u[:,:] = one_half*(q[:,1:end-1] + q[:,2:end])
    return u
end

function Iqv_nonperiodic(v,q)
    #= Interpolates a variable q from the q-grid to a variable v on the v-grid. =#
    v[:,:] = one_half*(q[1:end-1,2:end-1] + q[2:end,2:end-1])
    return v
end

function Iqv_periodic(v,q)
    #= Interpolates a variable q from the q-grid to a variable v on the v-grid. =#
    v[1:end-1,:] = one_half*(q[1:end-1,2:end-1] + q[2:end,2:end-1])
    v[end,:] = one_half*(q[1,2:end-1] + q[end,2:end-1])
    return v
end

function Ivq_nonperiodic(q,v)
    #= Interpolates a variable v from the v-grid to a variable q on the q-grid. =#
    q[2:end-1,2:end-1] = one_half*(v[1:end-1,:] + v[2:end,:])
    q[1,2:end-1] = one_minus_α_half*v[1,:]
    q[end,2:end-1] = one_minus_α_half*v[end,:]
    q[:,1] = zeero
    q[:,end] = zeero
    return q
end

function Ivq_periodic(q,v)
    #= Interpolates a variable v from the v-grid to a variable q on the q-grid. =#
    q[2:end,2:end-1] = one_half*(v[1:end-1,:] + v[2:end,:])
    q[1,2:end-1] = one_half*(v[1,:] + v[end,:])
    q[:,1] = zeero    # if initialised with zero these lines are redundant
    q[:,end] = zeero
    return q
end

function Iuq_nonperiodic(q,u)
    #= Interpolates a variable u from the u-grid to a variable q on the q-grid. =#
    q[2:end-1,2:end-1] = one_half*(u[:,1:end-1] + u[:,2:end])
    q[1,:] = zeero     # if initialised with zero these lines are redundant
    q[end,:] = zeero
    q[2:end-1,1] = one_minus_α_half*u[:,1]
    q[2:end-1,end] = one_minus_α_half*u[:,end]
    return q
end

function Iuq_periodic(q,u)
    #= Interpolates a variable u from the u-grid to a variable q on the q-grid. =#
    q[:,2:end-1] = one_half*(u[:,1:end-1] + u[:,2:end])
    q[:,1] = one_minus_α_half*u[:,1]
    q[:,end] = one_minus_α_half*u[:,end]
    return q
end

# ------------- 4-point interpolation between (T and q) and (u and v). ---------

function ITq_nonperiodic(q,T)
    #= Interpolates a variable T from the T-grid to a variable q on the q-grid. =#
    q[2:end-1,2:end-1] = one_quarter*(T[1:end-1,1:end-1] + T[1:end-1,2:end]
                                + T[2:end,1:end-1] + T[2:end,2:end])
    q[1,2:end-1] = one_half*(T[1,1:end-1] + T[1,2:end])
    q[end,2:end-1] = one_half*(T[end,1:end-1] + T[end,2:end])
    q[2:end-1,1] = one_half*(T[1:end-1,1] + T[2:end,1])
    q[2:end-1,end] = one_half*(T[1:end-1,end] + T[2:end,end])
    q[1,1] = T[1,1]         # no gradients of T across the boundaries
    q[1,end] = T[1,end]
    q[end,1] = T[end,1]
    q[end,end] = T[end,end]
    return q
end

function ITq_periodic(q,T)
    #= Interpolates a variable T from the T-grid to a variable q on the q-grid. =#
    q[2:end,2:end-1] = one_quarter*(T[1:end-1,1:end-1] + T[1:end-1,2:end]
                                + T[2:end,1:end-1] + T[2:end,2:end])
    q[1,2:end-1] = one_quarter*(T[1,1:end-1] + T[1,2:end]
                                + T[end,1:end-1] + T[end,2:end])
    q[2:end,1] = one_half*(T[1:end-1,1] + T[2:end,1])
    q[2:end,end] = one_half*(T[1:end-1,end] + T[2:end,end])

    q[1,1] = one_half*(T[1,1] + T[end,1])
    q[1,end] = one_half*(T[1,end] + T[end,end])
    return q
end

function IqT_nonperiodic(T,q)
    #= Interpolates a variable q from the q-grid to a variable T on the T-grid. =#
    T[:,:] = one_quarter*(q[1:end-1,1:end-1] + q[1:end-1,2:end]
                                + q[2:end,1:end-1] + q[2:end,2:end])
    return T
end

function IqT_periodic(T,q)
    #= Interpolates a variable q from the q-grid to a variable T on the T-grid. =#
    T[1:end-1,:] = one_quarter*(q[1:end-1,1:end-1] + q[1:end-1,2:end]
                                + q[2:end,1:end-1] + q[2:end,2:end])
    T[end,:] = one_quarter*(q[end,1:end-1] + q[end,2:end]
                                + q[1,1:end-1] + q[1,2:end])
    return T
end

function Iuv_nonperiodic(v,u)
    #= Interpolates a variable u from the u-grid to a variable v on the v-grid. =#
    v[2:end-1,:] = one_quarter*(u[1:end-1,1:end-1] + u[1:end-1,2:end]
                                + u[2:end,1:end-1] + u[2:end,2:end])
    v[1,:] = one_quarter*(u[1,1:end-1] + u[1,2:end])
    v[end,:] = one_quarter*(u[end,1:end-1] + u[end,2:end])
    return v
end

function Iuv_periodic(v,u)
    #= Interpolates a variable u from the u-grid to a variable v on the v-grid. =#
    v[1:end-1,:] = one_quarter*(u[1:end-1,1:end-1] + u[1:end-1,2:end] +
                         u[2:end,1:end-1] + u[2:end,2:end])
    v[end,:] = one_quarter*(u[1,1:end-1] + u[1,2:end] +
                     u[end,1:end-1] + u[end,2:end])
    return v
end

function Ivu_nonperiodic(u,v)
    #= Interpolates a variable v from the v-grid to a variable u on the u-grid. =#
    u[:,2:end-1] = one_quarter*(v[1:end-1,1:end-1] + v[1:end-1,2:end]
                                + v[2:end,1:end-1] + v[2:end,2:end])
    u[:,1] = one_quarter*(v[1:end-1,1] + v[2:end,1])
    u[:,end] = one_quarter*(v[1:end-1,end] + v[2:end,end])
    return u
end

function Ivu_periodic(u,v)
    #= Interpolates a variable u from the u-grid to a variable v on the v-grid. =#
    u[2:end,2:end-1] = one_quarter*(v[1:end-1,1:end-1] + v[1:end-1,2:end] +
                         v[2:end,1:end-1] + v[2:end,2:end])
    u[1,2:end-1] = one_quarter*(v[1,1:end-1] + v[1,2:end] +
                     v[end,1:end-1] + v[end,2:end])
    u[2:end,1] = one_quarter*(v[1:end-1,1] + v[2:end,1])
    u[2:end,end] = one_quarter*(v[1:end-1,end] + v[2:end,end])
    u[1,1] = one_quarter*(v[1,1] + v[end,1])
    u[1,end] = one_quarter*(v[1,end] + v[end,end])
    return u
end