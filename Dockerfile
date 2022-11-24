FROM rocker/rstudio:4.1.0

# Set global R options
RUN echo "options(repos = 'https://cloud.r-project.org')" > $(R --no-echo --no-save -e "cat(Sys.getenv('R_HOME'))")/etc/Rprofile.site
ENV RETICULATE_MINICONDA_ENABLED=FALSE

# Install Seurat's system dependencies
RUN apt-get clean all && \
	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y \
		libhdf5-dev \
    libcurl4-openssl-dev \
		libboost-all-dev \
		libssl-dev \
		libxml2-dev \
		libpng-dev \
		libxt-dev \
		zlib1g-dev \
		libbz2-dev \
		liblzma-dev \
		libglpk40 \
		libgit2-28 \
    libgeos-dev \
		libfftw3-dev \
		libgsl-dev \
		openjdk-8-jdk \
		python3-dev \
    python3-pip \
		wget \
		git

# RUN Rscript -e "install.packages(c('rmarkdown', 'tidyverse', 'workflowr', 'Seurat', 'SeuratObject'));"

# Install UMAP
RUN LLVM_CONFIG=/usr/lib/llvm-10/bin/llvm-config pip3 install llvmlite
RUN pip3 install numpy
RUN pip3 install umap-learn

# Install FIt-SNE
RUN git clone --branch v1.2.1 https://github.com/KlugerLab/FIt-SNE.git
RUN g++ -std=c++11 -O3 FIt-SNE/src/sptree.cpp FIt-SNE/src/tsne.cpp FIt-SNE/src/nbodyfft.cpp  -o bin/fast_tsne -pthread -lfftw3 -lm

# Install bioconductor
RUN R --no-echo --no-restore --no-save -e "install.packages('BiocManager')"

# Install bioconductor seurat dependencies & suggests
RUN R --no-echo --no-restore --no-save -e "BiocManager::install(c('multtest', 'S4Vectors', 'SummarizedExperiment', 'SingleCellExperiment', 'MAST', 'DESeq2', 'BiocGenerics', 'GenomicRanges', 'IRanges', 'rtracklayer', 'monocle', 'Biobase', 'limma', 'glmGamPoi'))"

# Install bioconductor monocle3 dependencies & suggests
RUN R --no-echo --no-restore --no-save -e "BiocManager::install(c('DelayedArray', 'DelayedMatrixStats', 'lme4', 'batchelor', 'HDF5Array', 'terra', 'ggrastr'))"

# Install CRAN suggests
RUN R --no-echo --no-restore --no-save -e "install.packages(c('VGAM', 'R.utils', 'metap', 'Rfast2', 'ape', 'enrichR', 'mixtools'))"

# Install hdf5r
RUN R --no-echo --no-restore --no-save -e "install.packages('hdf5r')"

# Install Seurat
RUN R --no-echo --no-restore --no-save -e "install.packages('remotes')"
RUN R --no-echo --no-restore --no-save -e "install.packages('Seurat')"

# Install SeuratDisk
RUN R --no-echo --no-restore --no-save -e "remotes::install_github('mojaveazure/seurat-disk')"

# Install Monocle3
RUN R --no-echo --no-restore --no-save -e "install.packages('devtools')"
RUN R --no-echo --no-restore --no-save -e "devtools::install_github('cole-trapnell-lab/monocle3')"

# Load Libraries
COPY ./scripts/cmd-load-libs.sh ./libs.txt ./tmp/
RUN chmod +x ./tmp/cmd-load-libs.sh
RUN /bin/bash ./tmp/cmd-load-libs.sh ./tmp/libs.txt

# COPY user-settings /home/rstudio/.rstudio/monitored/user-settings/user-settings
COPY .Rprofile /home/rstudio/

WORKDIR /home/rstudio