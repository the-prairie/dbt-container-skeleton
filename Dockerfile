FROM python:3.8-slim

RUN apt-get update \
    && apt-get install -y \
        git \
        bash-completion \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# Cloud SDK
RUN apt-get update && \
    apt-get install -y curl gnupg && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && \
    apt-get update -y && \
    apt-get install google-cloud-sdk -y   

# dbt-runner app
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV PYTHONUNBUFFERED 1
ENV PYTHONPATH /dbt-runner
ENV DBT_PROFILES_DIR /dbt-runner/dbt
ENV DBT_MODULES_DIR /dbt_modules
WORKDIR /dbt-runner

# Conveniences
ENV PROMPT_COMMAND history -a
RUN echo 'source /usr/share/bash-completion/bash_completion' >> /etc/bash.bashrc
RUN echo 'export HISTFILE=/dbt-runner/.developer/history' >> $HOME/.bashrc
RUN echo 'touch /dbt-runner/.developer/bashrc && source /dbt-runner/.developer/bashrc' >> $HOME/.bashrc

COPY requirements.txt requirements.txt
RUN pip install --upgrade pip
RUN pip install --ignore-installed -r requirements.txt && rm -rf /root/.cache

RUN mkdir -p /build_dbt_deps
COPY dbt/dbt_project.yml /build_dbt_deps/dbt_project.yml
COPY dbt/packages.yml /build_dbt_deps/packages.yml
RUN cd /build_dbt_deps \
    && dbt deps

ENTRYPOINT ["/bin/bash", "-c"]
