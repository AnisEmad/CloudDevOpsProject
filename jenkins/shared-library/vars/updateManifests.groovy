def call(Map args = [:]) {
    def manifestFile = args.manifestFile
    def imageUri = args.imageUri

    echo "Updating Kubernetes manifest: ${manifestFile}"
    echo "New image: ${imageUri}"

    sh """
        test -f ${manifestFile}
        sed -i 's|image:.*|image: ${imageUri}|g' ${manifestFile}
        grep -n 'image:' ${manifestFile}
    """
}