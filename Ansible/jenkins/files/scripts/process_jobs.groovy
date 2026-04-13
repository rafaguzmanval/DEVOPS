import org.yaml.snakeyaml.Yaml

def configFile = new File("/var/jenkins_home/jobs-config/jobs.yml")

if (configFile.exists()) {
    def yaml = new Yaml()
    def data = yaml.load(configFile.text)

    // Usamos una sintaxis que JCasC no intente "resolver" como variables de sistema
    def processItems 
    processItems = { items, parentPath ->
        items.each { item ->
            if (item.folder) {
                def folderName = item.folder.trim()
                // Evitamos el uso de ${} usando concatenación de strings (+)
                def fullFolderPath = parentPath ? parentPath + "/" + folderName : folderName
                
                println "Creating folder: [" + fullFolderPath + "]"
                folder(fullFolderPath) {
                    displayName(folderName)
                }

                if (item.children) {
                    processItems(item.children, fullFolderPath)
                }
            } 
            else if (item.pipeline) {
                def jobName = item.pipeline.trim()
                def fullJobPath = parentPath ? parentPath + "/" + jobName : jobName
                
                println "Creating pipeline: [" + fullJobPath + "]"
                pipelineJob(fullJobPath) {
                    definition {
                        cpsScm {
                            scm {
                                git {
                                    remote { url(item.repo) }
                                    branch(item.branch ?: 'main')
                                }
                            }
                            scriptPath(item.path ?: 'Jenkinsfile')
                        }
                    }
                    if (item.cron && item.cron.trim() != "") {
                        triggers {
                            scm(item.cron)
                        }
                    }
                }
            }
        }
    }

    if (data && data.config) {
        // Pasamos una cadena vacía explícita
        processItems(data.config, "")
    }
} else {
    println "⚠️ Archivo no encontrado"
}