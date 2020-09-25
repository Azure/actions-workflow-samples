# Action Samples for training and deploying machine learning models to Azure Machine Learning

We have released multiple actions to help you easily build a Continuous Integration and Continuous Delivery pipeline for a ML/AI project.
- [aml-workspace](https://github.com/Azure/aml-workspace) - Connects to or creates a new workspace
- [aml-compute](https://github.com/Azure/aml-compute) - Connects to or creates a new compute target in Azure Machine Learning
- [aml-run](https://github.com/Azure/aml-run) - Submits a ScriptRun, an Estimator or a Pipeline to Azure Machine Learning
- [aml-registermodel](https://github.com/Azure/aml-registermodel) - Registers a model to Azure Machine Learning
- [aml-deploy](https://github.com/Azure/aml-deploy) - Deploys a model and creates an endpoint for the model

We will be using the GitHub Actions for defining the workflow along with Azure ML services for model retraining pipeline, model management and operationalization.
<p align="center">
  <img src="img/ml-lifecycle.png" alt="Azure Machine Learning Lifecycle" width="700"/>
</p>

These actions are based on [DevOps principles](https://azure.microsoft.com/overview/what-is-devops/) and practices that increase the efficiency of workflows. For example, continuous integration, delivery, and deployment. 
We have applied these principles to the machine learning process, with the goal of:
- Faster experimentation and development of models
- Faster deployment of models into production
- Quality assurance

Here we have two template contains code and workflow definitions for a machine learning project that demonstrates how to automate an end to end ML/AI lifecycle.

1. **Simple template repository: [ml-template-azure](https://github.com/machine-learning-apps/ml-template-azure)**

    Go to this template and follow the getting started guide to setup an ML Ops process within minutes and learn how to use the Azure       Machine Learning GitHub Actions in combination. This template demonstrates a very simple process for training and deploying machine     learning models.

2. **Advanced template repository: [mlops-enterprise-template](https://github.com/Azure-Samples/mlops-enterprise-template)**

    This template demonstrates how approval processes can be included in the process and how training and deployment workflows can be       splitted. It also shows how workflows (e.g. deployment) can be triggered from pull requests. More enhancements will be added to this     template in the future to make it more enterprise ready.
    


# Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.


