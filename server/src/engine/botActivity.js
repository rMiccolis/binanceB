const k8s = require('@kubernetes/client-node');

const kc = new k8s.KubeConfig();
kc.loadFromCluster();

const k8sApi = kc.makeApiClient(k8s.CoreV1Api);

const main = async () => {
    try {
        print("heyyyyyy il job è in running!")
        print("questi sono i pod attivi:")
        const podsRes = await k8sApi.listNamespacedPod('binance-b', pretty="true");
        console.log(podsRes.body.items[0].metadata);
    } catch (err) {
        console.error(err);
    }
};

main();