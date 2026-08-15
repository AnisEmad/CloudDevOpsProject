def call(Map args = [:]) {
    def image = args.image
    def failOnCritical = args.get('failOnCritical', false)

    def exitCode = failOnCritical ? 1 : 0

    echo "Scanning image with Trivy: ${image}"

    sh """
        trivy image \
          --exit-code ${exitCode} \
          --severity HIGH,CRITICAL \
          --ignore-unfixed \
          ${image}
    """
}