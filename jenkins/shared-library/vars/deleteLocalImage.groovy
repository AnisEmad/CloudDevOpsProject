def call(Map args = [:]) {
    def images = args.images ?: []
    def imageList = images.join(' ')

    echo "Deleting local Docker images: ${imageList}"

    sh "docker rmi ${imageList} || true"
    sh "docker image prune -f || true"
}