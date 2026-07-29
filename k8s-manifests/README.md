# Kubernetes Manifest Apply Order

These manifests deploy the LearningSteps API into the `learningsteps` namespace and configure Azure Key Vault secret injection.

## Apply order

1. Create the namespace
   ```bash
   kubectl apply -f k8s-manifests/namespace.yaml
   ```

2. Install the Azure Key Vault Secrets Store CSI driver and Azure provider
   - The deployment uses `SecretProviderClass` and a CSI volume.
   - On AKS, install both the driver and the Azure provider with Helm.

   ```powershell
   helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
   helm repo add csi-secrets-store-provider-azure https://azure.github.io/secrets-store-csi-driver-provider-azure/charts
   helm repo update

   helm install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --namespace kube-system
   helm install csi-secrets-store-provider-azure csi-secrets-store-provider-azure/csi-secrets-store-provider-azure --namespace kube-system
   ```

   If the driver is already installed under a different release name, use:
   ```powershell
   helm install csi-secrets-store-provider-azure csi-secrets-store-provider-azure/csi-secrets-store-provider-azure --namespace kube-system --set secrets-store-csi-driver.install=false
   ```
   This avoids the resource ownership conflict for `ServiceAccount "secrets-store-csi-driver"`.

3. Apply the SecretProviderClass
   ```bash
   kubectl apply -f k8s-manifests/secretproviderclass.yaml
   ```

4. Apply the Deployment
   ```bash
   kubectl apply -f k8s-manifests/deployment.yaml
   ```

## Notes

- The deployment uses native Kubernetes env expansion for `DATABASE_URL`.
- The AKS cluster needs managed identity access to the Key Vault secret.
- If you want to apply all manifests after namespace creation:
  ```bash
  kubectl apply -f k8s-manifests/
  ```
