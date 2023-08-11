const k8s = require("@kubernetes/client-node");
const util = require('util')

const createConfigMapKeyRef = (configMapName, configMapKey) => {
    const configMapKeyRef = new k8s.V1ConfigMapKeySelector();
    configMapKeyRef.name = configMapName;
    configMapKeyRef.key = configMapKey;
    return configMapKeyRef;
};

const createSecretKeyRef = (secretName, secretKey) => {
    const secretKeyRef = new k8s.V1SecretKeySelector();
    secretKeyRef.name = secretName;
    secretKeyRef.key = secretKey;
    return secretKeyRef;
};

const createEnvValueFrom = (configMapKeyRef = null, secretKeyRef = null) => {
    const valueFrom = new k8s.V1EnvVarSource();
    if (configMapKeyRef) valueFrom.configMapKeyRef = configMapKeyRef;
    else if (secretKeyRef) valueFrom.secretKeyRef = secretKeyRef;
    return valueFrom;
};

const createEnvVar = (name, valueFrom) => {
    const env = new k8s.V1EnvVar();
    env.name = name;
    env.valueFrom = valueFrom;
    return env;
};

const createPod = (name, imageName, env = null, command = null) => {
    const pod_spec_container = new k8s.V1Container();
    pod_spec_container.name = name;
    pod_spec_container.image = imageName;
    if (env) pod_spec_container.env = env;
    if (command) pod_spec_container.command = command;
    return pod_spec_container;
};

const createTemplateContainers = (containers, restartPolicy) => {
    const templateSpec = new k8s.V1PodSpec();
    templateSpec.containers = containers;
    templateSpec.restartPolicy = restartPolicy;
    return templateSpec;
};

const createJobSpecTemplate = (templateSpec) => {
    const jobSpecTemplate = new k8s.V1PodTemplateSpec();
    jobSpecTemplate.spec = templateSpec;
    return jobSpecTemplate;
};

const createJobSpec = (jobSpecTemplate, ttlSecondsAfterFinished, parallelism, backoffLimit) => {
    const jobSpec = new k8s.V1JobSpec();
    jobSpec.ttlSecondsAfterFinished = ttlSecondsAfterFinished;
    jobSpec.parallelism = parallelism;
    jobSpec.backoffLimit = backoffLimit;
    jobSpec.template = jobSpecTemplate;
    return jobSpec;
};

const createJobMetadata = (jobName, namespace) => {
    const metadata = new k8s.V1ObjectMeta();
    metadata.name = jobName;
    metadata.namespace = namespace;
    return metadata;
};

const createJobObject = (metadata, jobSpec) => {
    const job = new k8s.V1Job();
    job.apiVersion = "batch/v1";
    job.kind = "Job";
    job.metadata = metadata;
    job.spec = jobSpec;
    return job;
};

/**
 *
 *
 * @param {String} jobName
 * @param {String} namespace
 * @param {Array[Object]} [containers=[]] this is an array of Objects like: [{name: 'podName', imageName: 'imagename', env: { configMaps: [{envName: 'envName', configMapName: 'configMapName', configMapKey: 'configMapKey}], secrets: [{envName: 'envName', secretName: 'secretName', secretKey: 'secretKey}]}, command: ['command', 'command2']}]
 * @param {String} templateRestartPolicy
 * @param {number} jobTtlSecondsAfterFinished
 * @param {number} [parallelism=1]
 * @param {number} [backoffLimit=4]
 */
const createJob = (jobName, namespace, containers = [], templateRestartPolicy, jobTtlSecondsAfterFinished, parallelism = 1, backoffLimit = 4) => {
    // create pods stage
    let pods = [];
    for (let container of containers) {
        // create env stage
        let env = [];
        if (container.env?.configMaps) {
            for (let config of container.env.configMaps) {
                let tempConfigMapKeyRef = createConfigMapKeyRef(config.configMapName, config.configMapKey);
                let tempEnvValueFrom = createEnvValueFrom(tempConfigMapKeyRef);
                let tempEnv = createEnvVar(config.envName, tempEnvValueFrom);
                env.push(tempEnv);
                
            }
        }
        if (container.env?.secrets) {
            for (let secret of container.env?.secrets) {
                let tempSecretKeyRef = createSecretKeyRef(secret.secretName, secret.secretKey);
                let tempEnvValueFrom = createEnvValueFrom(null, tempSecretKeyRef);
                let tempEnv = createEnvVar(secret.envName, tempEnvValueFrom);
                env.push(tempEnv);
            }
        }
        let tempPod = createPod(container.name, container.imageName, env, container.command);
        pods.push(tempPod);
    }

    // create template containers stage
    let templateContainers = createTemplateContainers(pods, templateRestartPolicy);

    // create job spec template stage
    let jobSpecTemplate = createJobSpecTemplate(templateContainers);

    // create job spec stage
    let jobSpec = createJobSpec(jobSpecTemplate, jobTtlSecondsAfterFinished, parallelism, backoffLimit);

    // create job metadata
    let metadata = createJobMetadata(jobName, namespace);

    // create the job Object
    let job = createJobObject(metadata, jobSpec);

    // console.log(util.inspect(job, {showHidden: false, depth: null, colors: true}))

    return job;
};

module.exports = {
    createJob,
};
