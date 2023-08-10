const k8s = require('@kubernetes/client-node');

const kc = new k8s.KubeConfig();
kc.loadFromCluster();

const k8sApi = kc.makeApiClient(k8s.CoreV1Api);

const main = async () => {
    try {
        console.log("This was a test and the job is running!")
        console.log(":")
        const podsRes = await k8sApi.listNamespacedPod('binance-b', pretty="true");
        console.log(podsRes.body.items.map(el => el.metadata.name));
        console.log(process.env);
    } catch (err) {
        console.error(err);
    }
};

main();