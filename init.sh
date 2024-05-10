# Run this script once to install argocd and istio
# all the further updates will deploy automatically via argocd upon new tags on main branch
k3d cluster delete
k3d cluster create --agents 2

# Install Istio and include it to PATH
eval "$(curl -L https://istio.io/downloadIstio | sh - | sed -n '/export PATH.*/p')"

# Creates namespace where the apps will run
kubectl create namespace apps

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl apply -f argocd-app-deploy.yaml

# Install Istio and set it to work with default namespace (use specific namespaces for your apps in prod!)
kubectl create namespace istio-system
istioctl install -y
kubectl label namespace apps istio-injection=enabled

# addons
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.21/samples/addons/prometheus.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.21/samples/addons/grafana.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.21/samples/addons/kiali.yaml

echo "Argo Password: $(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)"