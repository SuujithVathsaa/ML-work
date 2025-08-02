Machine Learning Project with Scikit-learn

This repository contains my first machine learning project, a regression model developed using Python and scikit-learn in a Google Colab notebook. The primary goal of this project was to predict the solubility of molecules (logS) using various molecular descriptors as features.
Project Structure

The project notebook (ml_using_sykitlean.ipynb) follows these key steps:

    Data Acquisition: Loading the dataset directly from a URL.

    Data Preprocessing: Separating the features (X) from the target variable (Y).

    Model Splitting: Dividing the data into training and testing sets to evaluate model performance on unseen data.

    Model Training: Building and training two different regression models.

    Model Evaluation: Assessing the performance of the trained models using standard metrics.

    Data Visualization: Creating plots to visualize the model predictions and performance.

Dataset

The dataset used is the Delaney solubility dataset, which is publicly available on GitHub. It contains molecular descriptors and the corresponding logS (solubility) values for 1144 molecules.

The columns in the dataset are:

    MolLogP: The octanol-water partition coefficient.

    MolWt: Molecular weight.

    NumRotatableBonds: Number of rotatable bonds.

    AromaticProportion: The proportion of heavy atoms in aromatic systems.

    logS: The target variable, representing solubility in water (log scale).

Methodology
Data Splitting

The dataset was split into training and testing sets with a test_size of 0.2 and a random_state of 100 to ensure reproducibility.
Models Used

I implemented and compared two regression models from the scikit-learn library:

    Linear Regression: A simple yet powerful linear model.

    Random Forest Regressor: An ensemble model that uses multiple decision trees to improve accuracy.

Model Performance

The models were evaluated based on Mean Squared Error (MSE) and R-squared (R2) scores. The results are summarized in the table below:

Method
	

Training MSE
	

Training R2
	

Test MSE
	

Test R2

Linear Regression
	

1.007536
	

0.764505
	

1.020695
	

0.789162

Random Forest
	

1.028228
	

0.759669
	

1.407688
	

0.709223

The Linear Regression model appears to perform slightly better on the test data with a lower MSE and a higher R2 score.
Visualizations

The notebook includes plots generated using matplotlib and seaborn to better understand the results. A key visualization is a scatter plot comparing the measured vs. predicted solubility values, which helps to visually assess how well the Linear Regression model fits the data.
How to Interact with the Notebook

This project can be easily run in Google Colab:

    Upload the ml_using_sykitlean.ipynb file to your Google Drive.

    Open the notebook with Google Colaboratory.

    Navigate to Runtime > Run all to execute all the cells and reproduce the results.
<img width="580" height="456" alt="Untitled" src="https://github.com/user-attachments/assets/b8b83ccf-8a50-4fb1-bd90-d9cfdbbd3701" />
<img width="476" height="456" alt="Untitled" src="https://github.com/user-attachments/assets/1bb906cf-48fc-4b22-8c6a-de41bd1df1d9" />



Dependencies

The following libraries are required to run the notebook. They are commonly available in the Colab environment.

    pandas

    scikit-learn

    matplotlib

    seaborn
