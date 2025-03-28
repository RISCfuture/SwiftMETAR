public extension Remark {

    /// Types of columnar vortices.
    enum TornadicActivityType: String, Codable, Equatable, RegexCases, Sendable {

        /// An intense columnar vortex that reaches the ground.
        case tornado = "TORNADO"

        /// A columnar vortex that doesn't reach the ground.
        case funnelCloud = "FUNNEL CLOUD"

        /// A columnar vortex that reaches the water surface.
        case waterspout = "WATERSPOUT"
    }
}
