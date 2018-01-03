"""
```jldoctest
julia> flow_graph = DiGraph(8) # Create a flow graph
julia> flow_edges = [
(1, 2, 10), (1, 3, 5),  (1, 4, 15), (2, 3, 4),  (2, 5, 9),
(2, 6, 15), (3, 4, 4),  (3, 6, 8),  (4, 7, 16), (5, 6, 15),
(5, 8, 10), (6, 7, 15), (6, 8, 10), (7, 3, 6),  (7, 8, 10)
]
julia> capacity_matrix = zeros(Int, 8, 8) # Create a capacity matrix
julia> for e in flow_edges
    u, v, f = e
    add_edge!(flow_graph, u, v)
    capacity_matrix[u, v] = f
end
julia> f, F = multiroute_flow(flow_graph, 1, 8, capacity_matrix, routes = 2) # Run default multiroute_flow with an integer number of routes = 2
julia> f, F = multiroute_flow(flow_graph, 1, 8, capacity_matrix, routes = 1.5) # Run default multiroute_flow with a noninteger number of routes = 1.5
julia> points = multiroute_flow(flow_graph, 1, 8, capacity_matrix) # Run default multiroute_flow for all the breaking points values
julia> f, F = multiroute_flow(points, 1.5) # Then run multiroute flow algorithm for any positive number of routes
julia> f = multiroute_flow(points, 1.5, valueonly = true)
julia> f, F, labels = multiroute_flow(flow_graph, 1, 8, capacity_matrix, algorithm = BoykovKolmogorovAlgorithm(), routes = 2) # Run multiroute flow algorithm using Boykov-Kolmogorov algorithm as maximum_flow routine
```
"""
function multiroute_flow(
    flow_graph::AbstractGraph,                    # the input graph
    source::Integer,                        # the source vertex
    target::Integer,                        # the target vertex
    capacity_matrix::AbstractMatrix{T} =  # edge flow capacities
        DefaultCapacity(flow_graph);
    flow_algorithm::AbstractFlowAlgorithm  =    # keyword argument for algorithm
    PushRelabelAlgorithm(),
    mrf_algorithm::AbstractMultirouteFlowAlgorithm  =    # keyword argument for algorithm
    KishimotoAlgorithm(),
    routes::R = 0              # keyword argument for number of routes (0 = all values)
    ) where T where R <: Real

    # a flow with a set of 1-disjoint paths is a classical max-flow
    (routes == 1) &&
    return maximum_flow(flow_graph, source, target, capacity_matrix, flow_algorithm)

    # routes > λ (connectivity) → f = 0
    λ = maximum_flow(flow_graph, source, target, DefaultCapacity(flow_graph),
    algorithm = flow_algorithm)[1]
    (routes > λ) && return empty_flow(capacity_matrix, flow_algorithm)

    # For other cases, capacities need to be Floats
    if !(T<:AbstractFloat)
        capacity_matrix = convert(AbstractMatrix{Float64}, capacity_matrix)
    end

    # Ask for all possible values (breaking points)
    (routes == 0) &&
    return emrf(flow_graph, source, target, capacity_matrix, flow_algorithm)
    # The number of routes is a float → EMRF
    (R <: AbstractFloat) &&
    return emrf(flow_graph, source, target, capacity_matrix, flow_algorithm, routes)

    # Other calls
    return multiroute_flow(flow_graph, source, target, capacity_matrix,
    flow_algorithm, mrf_algorithm, routes)
end
