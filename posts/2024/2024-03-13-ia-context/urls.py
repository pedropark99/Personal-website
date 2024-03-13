import bs4
from langchain import hub
from langchain_community.document_loaders import DirectoryLoader, TextLoader, PythonLoader
from langchain_community.vectorstores import Chroma
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

# paths = ['migracao_scripts/main.py', 'migracao_scripts/redirect_general_calls.py', 'migracao_scripts/redirect_spark_sql_calls.py', 'migracao_scripts/redirect_spark_table_calls.py', 'migracao_scripts/redirect_to_dataforge.py', 'migracao_scripts/remove_runs_commands.py', 'migracao_scripts/__init__.py', 'migracao_scripts/adf/adf_changes_bmg.py', 'migracao_scripts/adf/adf_copy_triggers_to_clients_dev.py', 'migracao_scripts/adf/adf_functions.py', 'migracao_scripts/adf/adf_get_triggers.py', 'migracao_scripts/adf/adf_legacy_workflow.py', 'migracao_scripts/adf/adf_list_pipe_per_owner.py', 'migracao_scripts/adf/main.py', 'migracao_scripts/databricks_queries/identify_recent_tables.py', 'migracao_scripts/databricks_queries/list_cells_tables.py', 'migracao_scripts/databricks_queries/__init__.py', 'migracao_scripts/mapeamento_tabelas/rebuild_table_mapping.py', 'migracao_scripts/mapeamento_tabelas/update_blipcs_views.py', 'migracao_scripts/mapeamento_tabelas/update_source_views.py', 'migracao_scripts/migrar_tabelas/create_blipcs_views.py', 'migracao_scripts/migrar_tabelas/create_source_views.py', 'migracao_scripts/migrar_tabelas/depara_dslablegacy_clients.py', 'migracao_scripts/table_references/notebook_table_dependencies.py', 'migracao_scripts/table_references/parse_table_references.py', 'migracao_scripts/table_references/__init__.py', 'migracao_scripts/utils/check_info_notebook.py', 'migracao_scripts/utils/collect_all_notebooks_path.py', 'migracao_scripts/utils/copy_notebooks.py', 'migracao_scripts/utils/copy_workflows.py', 'migracao_scripts/utils/databricks_api.py', 'migracao_scripts/utils/filesystem.py', 'migracao_scripts/utils/find_regex_example.py', 'migracao_scripts/utils/get_mapped_table.py', 'migracao_scripts/utils/notebook_assignments.py', 'migracao_scripts/utils/text.py', 'migracao_scripts/utils/__init__.py']
# paths = ['C:/Users/pedro.duarte/Documents/CSPS-JOBS/' + p  for p in paths]
# def read_text_file(path):
#     with open(path, 'r', encoding = "utf-8") as file_connection:
#         return file_connection.read()

# codebase = [read_text_file(p) for p in paths]
# codebase = '\n'.join(codebase)
loader = DirectoryLoader(
    'C:/Users/pedro.duarte/Documents/CSPS-JOBS/migracao_scripts',
    glob = '**/*.py',
    show_progress=True,
    loader_cls=PythonLoader
)
codebase = loader.load()

text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
splits = text_splitter.split_documents(codebase)
vectorstore = Chroma.from_documents(documents=splits, embedding=OpenAIEmbeddings())

# Retrieve and generate using the relevant snippets of the blog.
retriever = vectorstore.as_retriever()
prompt = hub.pull("rlm/rag-prompt")
llm = ChatOpenAI(model_name="gpt-3.5-turbo", temperature=0)


def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)


rag_chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)

