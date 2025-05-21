import kopf
import kubernetes.client
from kubernetes.client.rest import ApiException
import logging

# Configure Kubernetes client
configuration = kubernetes.client.Configuration()
kubernetes.config.load_incluster_config()
api = kubernetes.client.CoreV1Api()

# Handler for when a SimpleApp is created or updated
@kopf.on.create('example.com', 'v1', 'simpleapps')
@kopf.on.update('example.com', 'v1', 'simpleapps')
def handle_simpleapp(spec, name, namespace, **kwargs):
    app_name = spec.get('name', 'default-app')
    desired_replicas = spec.get('replicas', 1)
    
    # Get current Pods with matching label
    label_selector = f"app={name}"
    try:
        pods = api.list_namespaced_pod(namespace, label_selector=label_selector)
        current_replicas = len(pods.items)
    except ApiException as e:
        logging.error(f"Error listing pods: {e}")
        current_replicas = 0

    # Create or delete Pods to match desired replicas
    pod_template = {
        'metadata': {
            'name': f"{name}-pod",
            'labels': {'app': name}
        },
        'spec': {
            'containers': [{
                'name': 'nginx',
                'image': 'nginx:latest'
            }]
        }
    }

    # Scale up: Create Pods if needed
    for i in range(current_replicas, desired_replicas):
        pod_template['metadata']['name'] = f"{name}-pod-{i}"
        try:
            api.create_namespaced_pod(namespace, pod_template)
            logging.info(f"Created pod {pod_template['metadata']['name']}")
        except ApiException as e:
            logging.error(f"Error creating pod: {e}")

    # Scale down: Delete excess Pods
    for i in range(current_replicas - 1, desired_replicas - 1, -1):
        pod_name = f"{name}-pod-{i}"
        try:
            api.delete_namespaced_pod(pod_name, namespace)
            logging.info(f"Deleted pod {pod_name}")
        except ApiException as e:
            logging.error(f"Error deleting pod: {e}")

    # Update status
    return {'replicas': current_replicas}

# Handler for when a SimpleApp is deleted
@kopf.on.delete('example.com', 'v1', 'simpleapps')
def handle_delete(name, namespace, **kwargs):
    label_selector = f"app={name}"
    try:
        pods = api.list_namespaced_pod(namespace, label_selector=label_selector)
        for pod in pods.items:
            api.delete_namespaced_pod(pod.metadata.name, namespace)
            logging.info(f"Deleted pod {pod.metadata.name}")
    except ApiException as e:
        logging.error(f"Error deleting pods: {e}")