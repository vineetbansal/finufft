function comparisons

N1=128;
N2=128;
N3=128;
M=N1*N2*N3;
x=rand(1,M)*2*pi-pi;
y=rand(1,M)*2*pi-pi;
z=rand(1,M)*2*pi-pi;
data_in=randn(1,M);
finufft_nthreads=1;

ALGS={};

addpath('..');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ALG=struct;
ALG.name='finufft(1e-3)';
ALG.algopts.eps=1e-3;
ALG.algopts.opts.nthreads=finufft_nthreads; ALG.algopts.opts.spread_sort=0; ALG.algopts.isign=1;
ALG.init=@dummy_init; ALG.run=@run_finufft3d1;
ALGS{end+1}=ALG;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ALG=struct;
ALG.name='finufft(1e-5)';
ALG.algopts.eps=1e-5;
ALG.algopts.opts.nthreads=finufft_nthreads; ALG.algopts.opts.spread_sort=0; ALG.algopts.isign=1;
ALG.init=@dummy_init; ALG.run=@run_finufft3d1;
ALGS{end+1}=ALG;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ALG=struct;
ALG.name='finufft(1e-7)';
ALG.algopts.eps=1e-7;
ALG.algopts.opts.nthreads=finufft_nthreads; ALG.algopts.opts.spread_sort=0; ALG.algopts.isign=1;
ALG.init=@dummy_init; ALG.run=@run_finufft3d1;
ALGS{end+1}=ALG;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ALG=struct;
ALG.name='finufft(1e-9)';
ALG.algopts.eps=1e-9;
ALG.algopts.opts.nthreads=finufft_nthreads; ALG.algopts.opts.spread_sort=0; ALG.algopts.isign=1;
ALG.init=@dummy_init; ALG.run=@run_finufft3d1;
ALGS{end+1}=ALG;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ALG=struct;
ALG.name='finufft(1e-14)';
ALG.algopts.eps=1e-14;
ALG.algopts.opts.nthreads=finufft_nthreads; ALG.algopts.opts.spread_sort=0; ALG.algopts.isign=1;
ALG.init=@dummy_init; ALG.run=@run_finufft3d1;
ALGS{end+1}=ALG;


addpath('nfft-3.3.1/matlab/nfft');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ALG=struct;
ALG.name='nfft(1)';
ALG.algopts.m=1;
ALG.init=@init_nfft; ALG.run=@run_nfft;
ALGS{end+1}=ALG;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ALG=struct;
ALG.name='nfft(2)';
ALG.algopts.m=2;
ALG.init=@init_nfft; ALG.run=@run_nfft;
ALGS{end+1}=ALG;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ALG=struct;
ALG.name='nfft(3)';
ALG.algopts.m=3;
ALG.init=@init_nfft; ALG.run=@run_nfft;
ALGS{end+1}=ALG;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ALG=struct;
ALG.name='nfft(4)';
ALG.algopts.m=4;
ALG.init=@init_nfft; ALG.run=@run_nfft;
ALGS{end+1}=ALG;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ALG=struct;
ALG.name='nfft(5)';
ALG.algopts.m=5;
ALG.init=@init_nfft; ALG.run=@run_nfft;
ALGS{end+1}=ALG;

results=run_algs(ALGS,x,y,z,data_in,N1,N2,N3);
print_accuracy_comparison_and_timings(ALGS,results);

function results=run_algs(ALGS,x,y,z,data_in,N1,N2,N3)
results={};
for j=1:length(ALGS)
    ALG=ALGS{j};
    RESULT=struct;
    
    fprintf('Initializing %s...\n',ALG.name);
    tA=tic;
    init_data=ALG.init(ALG.algopts,x,y,z,N1,N2,N3);
    RESULT.init_time=toc(tA);
    
    fprintf('Running %s...\n',ALG.name);
    tA=tic;
    RESULT.data_out=ALG.run(ALG.algopts,x,y,z,data_in,N1,N2,N3,init_data);
    RESULT.run_time=toc(tA);
    
    RESULT.tot_time=RESULT.init_time+RESULT.run_time;
    
    results{j}=RESULT;
end;

function print_accuracy_comparison_and_timings(ALGS,results)
MM=length(ALGS);

max_diffs=zeros(MM,MM);
avg_diffs=zeros(MM,MM);
for j1=1:MM
    X1=results{j1}.data_out;
    for j2=1:MM
        X2=results{j2}.data_out;
        m0=(max(abs(X1(:)))+max(abs(X2(:))))/2;
        max_diffs(j1,j2)=max(abs(X1(:)-X2(:)))/m0;
        avg_diffs(j1,j2)=mean(abs(X1(:)-X2(:)))/m0;
    end;
end;

fprintf('Max. differences:\n');
fprintf('%15s ','');
for j2=1:MM
    fprintf('%15s ',ALGS{j2}.name);
end;
fprintf('\n');
for j1=1:MM
    fprintf('%15s ',ALGS{j1}.name);
    for j2=1:MM
        fprintf('%15g ',max_diffs(j1,j2));
    end;
    fprintf('\n');
end;
fprintf('\n');
fprintf('Avg. differences:\n');
fprintf('%15s ','');
for j2=1:MM
    fprintf('%15s ',ALGS{j2}.name);
end;
fprintf('\n');
for j1=1:MM
    fprintf('%15s ',ALGS{j1}.name);
    for j2=1:MM
        fprintf('%15g ',avg_diffs(j1,j2));
    end;
    fprintf('\n');
end;
fprintf('\n');
%fprintf('%15s %15s %15s %15s\n','Algorithm','Init time (s)','Run time (s)','RAM (GB)');
fprintf('%15s %15s %15s %15s\n','Algorithm','Init time (s)','Run time (s)','Tot time (s)');
for j1=1:MM
    %fprintf('%15s %15.3f %15.3f %15.3f\n',ALGS{j1}.name,results{j1}.init_time,results{j1}.run_time,results{j1}.memory_used);
    fprintf('%15s %15.3f %15.3f %15.3f\n',ALGS{j1}.name,results{j1}.init_time,results{j1}.run_time,results{j1}.tot_time);
end;
fprintf('\n');

function init_data=dummy_init(algopts,x,y,z,N1,N2,N3)
init_data=struct;

function data_out=run_finufft3d1(algopts,x,y,z,data_in,N1,N2,N3,init_data)
data_out=finufft3d1(x,y,z,data_in,algopts.isign,algopts.eps,N1,N2,N3,algopts.opts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Instructions for installing nfft
% Download current source from here: https://www-user.tu-chemnitz.de/~potts/nfft/download.php
% Extract to comparisons/nfft-3.3.1
% cd to nfft-3.3.1 and run
% > ./configure --with-matlab-arch=glnxa64 --with-matlab=/home/magland/MATLAB/R2017a --enable-all --enable-openmp
%     where /home/magland/MATLAB/R2017a is the appropriate matlab path and set glnxa64 to be the appropriate architecture
% > make
% Note: to test with only a single thread, omit --enable-all and --enable-openmp
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function init_data=init_nfft(algopts,x,y,z,N1,N2,N3)

M=length(x);
N=[N1;N2;N3];
%plan=nfft(3,N,M); 
n=2^(ceil(log(max(N))/log(2))+1);

ticA=tic;
plan=nfft(3,N,M,n,n,n,algopts.m,bitor(PRE_PHI_HUT,bitor(PRE_PSI,NFFT_OMP_BLOCKWISE_ADJOINT)),FFTW_MEASURE); % use of nfft_init_guru
fprintf('time for creating nfft plan: %g s\n',toc(ticA));

xyz=cat(1,x,y,z)';
plan.x=(xyz)/(2*pi); % set nodes in plan
ticA=tic;
nfft_precompute_psi(plan); % precomputations
fprintf('time for nfft_precompute_psi: %g s\n',toc(ticA));

init_data.plan=plan;


function X=run_nfft(algopts,x,y,z,d,N1,N2,N3,init_data)

plan=init_data.plan;

M=length(x);
plan.f=d';
nfft_adjoint(plan);
X=reshape(plan.fhat,[N1,N2,N3])/M;
