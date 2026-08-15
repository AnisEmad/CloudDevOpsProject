def call(Map args = [:]) {
    def context = args.context ?: '.'
    def localImage = args.localImage

    echo "Building Docker image: ${localImage}"
    echo "Build context: ${context}"

    sh "docker build -t ${localImage} ${context}"
}