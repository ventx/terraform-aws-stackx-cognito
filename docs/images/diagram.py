from urllib.request import urlretrieve

from diagrams import Cluster, Diagram
from diagrams.aws.compute import ElasticKubernetesService
from diagrams.aws.security import KeyManagementService
from diagrams.aws.security import IdentityAndAccessManagementIam
from diagrams.aws.security import IdentityAndAccessManagementIamRole
from diagrams.aws.management import Cloudwatch
from diagrams.aws.compute import Fargate
from diagrams.k8s.controlplane import KubeProxy
from diagrams.custom import Custom

vpccni_url = "https://user-images.githubusercontent.com/50456/83688420-3a52a080-a5a2-11ea-8ebd-da3813717d37.png"
vpccni_icon = "icon-vpccni.png"
urlretrieve(vpccni_url, vpccni_icon)

with Diagram("terraform-aws-stackx-cluster", outformat="png", filename="screenshot1", show=False):
    with Cluster("EKS"):

      eks = ElasticKubernetesService("EKS")
      kms = KeyManagementService("Secrets Encryption")
      cr = IdentityAndAccessManagementIamRole("Cluster Role")
      oidc = IdentityAndAccessManagementIam("OIDC Provider")
      fg = Fargate("Fargate Profile")
      cloudwatch = Cloudwatch("Control-Plane Logs")
      cni = Custom("AWS VPC", vpccni_icon)
      proxy = KubeProxy("Kube Proxy")
      eks >> [kms, cloudwatch, oidc, fg]
