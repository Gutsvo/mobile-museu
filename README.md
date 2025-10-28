# Análise da API

## URL da documentação 
#### https://github.com/metmuseum/openaccess?tab=readme-ov-file
## URL de acesso a API
#### https://metmuseum.github.io/

## Métodos disponíveis.
#### Objects: Uma lista de todos os IDs de Objetos válidos disponíveis para acesso.
#### Object: Um registro de um objeto, contendo todos os dados de acesso aberto sobre esse objeto, incluindo sua imagem (se a imagem estiver disponível em Acesso Aberto).
#### Departments: Uma lista de todos os departamentos válidos, com seus IDs e nomes de exibição.
#### Search: Uma lista de todos os IDs de Objetos para objetos que contêm a consulta de pesquisa nos dados do objeto. --> Não será utilizado.

## Atributos/parametros solicitados por cada método
##  Objects
### Identificação, Tipo, Descrição:
#### total, int, O número total de objetos disponíveis publicamente.
#### objectIDs, intarray, Uma matriz contendo o ID do objeto de um objeto disponível publicamente.

##  Object
### Identificação, Tipo, Descrição:
#### objectID, 0-9, O ID de objeto exclusivo para um objeto.

##  Departments
### Identificação, Tipo, Descrição:
#### departments, array, Um array contendo os objetos JSON que contêm o departmentId e o nome de exibição de cada departamento. O departmentId deve ser usado como parâmetro de consulta no endpoint `/objects`.
#### departmentId, int, ID do departamento como um inteiro. O departmentId deve ser usado como parâmetro de consulta no endpoint `/objects`.
#### displayName, string, Nome de exibição de um departamento.

<!-- ##  Search
### Identificação, Tipo, Descrição:
#### q, 
#### isHighlight
#### 
#### 
#### 
#### 
#### 
#### 
#### 
#### 
#### -->

## Dados retornados para cada método.
##  Objects
### Identificação, Tipo, Descrição:
#### 

##  Object
### Identificação, Tipo, Descrição:
####

##  Departments
### Identificação, Tipo, Descrição:
#### departments, array, Um array contendo os objetos JSON que contêm o departmentId e o nome de exibição de cada departamento. O departmentId deve ser usado como parâmetro de consulta no endpoint `/objects`.
#### departmentId, int, ID do departamento como um inteiro. O departmentId deve ser usado como parâmetro de consulta no endpoint `/objects`.
#### displayName, string, Nome de exibição de um departamento.
