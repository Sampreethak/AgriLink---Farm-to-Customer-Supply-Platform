% -------------------------------------------------------------------
%  @LaTeX-class-file{
%     filename        = "iitgcsethesis.cls",
%     author          = "Mohit Kumar, CSE, IITG",
%     version         = "1.0",
%     date            = "4th July 2015",
%     codetable       = "ISO/ASCII",
%     keywords        = "LaTeX, pdfLaTeX, iitgcsethesis",
%     supported       = "send email to mohit.2013@iitg.ernet.in",
%     docstring       = "A thesis class for an IIT Guwahati CSE Dept thesis. (pdfLaTeX version)"
% --------------------------------------------------------------------

% process using the LaTeX2e format
\NeedsTeXFormat{LaTeX2e}

% provides the following class to users
\ProvidesClass{iitgcsethesisa5}[17/01/2015 custom Thesis class for IITG CSE Research Scholars]

% twoside, openright to start new chapters from odd numbered pages
\LoadClass[twoside,openright,10pt]{report}

% for setting up margins
\RequirePackage[left=2cm,right=1cm,top=2cm,bottom=2cm]{geometry}

% for including images (everything apart from eps images)
\RequirePackage{graphicx}

% for setting custom width between lines
\RequirePackage{setspace}

% Both of these are required for if statements
\RequirePackage{ifthen}
\RequirePackage{xifthen}

% for making the entries in the contents as links
% for adding phantomsection
\RequirePackage{hyperref}

% to align the header right
\RequirePackage{titlesec}

% for quotations on top, besides the chapter number
\RequirePackage{quotchap}

% big letter at start of chapter in the content part
\RequirePackage{sectsty}

% for arbitrary font sizes
\RequirePackage{anyfontsize}

% to wrap image in vita section
\RequirePackage{wrapfig}

% to wrap image in vita section
\RequirePackage{emptypage}

% for fancy headers at the top of the pages
\RequirePackage{fancyhdr}

% for list of symbols
%\RequirePackage{nomencl}

% for algorithms and list of algorithms
\RequirePackage{algorithm}

% remove the ugly red boxes around the hyperlinks & gives them nice colors
\RequirePackage{xcolor}
\hypersetup{
    colorlinks,
    linkcolor={red!50!black},
    citecolor={blue!50!black},
    urlcolor={blue!80!black}
}

% setup custom fancy style
\fancyhead{}
\fancyfoot{}
\fancyhead[LO]{\leftmark}
\fancyhead[RE]{\rightmark}
%\fancyhead[CE,CO]{\@title}
\fancyfoot[CE,CO]{\thepage}

% set no indent at paragraph begining
\setlength\parindent{0pt}

% set a new page counter
% for continuing page numbers after abstract section
\newcounter{savepage}


% new command for submission month and year
\newcommand{\submissionMonth}[1]{\gdef\@submissionMonth{#1}}
\newcommand{\submissionYear}[1]{\gdef\@submissionYear{#1}}

% for supervisor names on front page
% manages for one and two supervisor names accordingly
\newcommand{\supervisor}[2][]{%
    \ifthenelse{\isempty{#1}}
            {\newcommand{\cbox}{\makebox[2.5in]{\hrulefill} \\ #2} \newcommand{\tbox}{#2}}
            % if no title option given
            {\newcommand{\cbox}{\makebox[2.5in]{\hrulefill} \hfill \makebox[2.5in]{\hrulefill} \\ #1  \hfill  #2} \newcommand{\tbox}{#2\\#1}
            } % if author has 2 supervisors
}

% supervisor profile for certificate page
\newcommand{\supervisorprofile}[2][]{
    \ifthenelse{\isempty{#1}}
	{\newcommand{\certhdr}{#2}} % if only one supervisor
	{\newcommand{\certhdr}{	\begin{minipage}{.50\textwidth}{\large {#2}}\end{minipage}%
				\begin{minipage}{.50\textwidth}
					\begin{flushright}
						{\large{#1}}										
					\end{flushright}
				\end{minipage}%
			}
		}
}


% holds the date for certificate page & acknowledgements page
\newcommand{\certdate}[1]{\gdef\@certdate{#1}}

% correct the \cleardoublepage behaviour
% incomplete
%\renewcommand{\cleardoublepage}{
%  \clearpage
%  \ifodd\value{page}\hbox{}\clearpage\fi
%}

% title page
% renew the maketitle command to make custom title page
\renewcommand{\maketitle}{%
  \begin{titlepage}
    %\vspace*{0.1in}
    \begin{center}
		\begin{spacing}{1.5}
			{\Large {\textbf {\@title}}}\\[0.5 cm]
		\end{spacing}
		{ {\textit {Thesis submitted in partial fulf{i}lment of the requirements \\ for the award of the degree of}}}\\[0.3 cm]
		\includegraphics[scale=0.2]{phd_text.pdf}\\[0.3 cm]
		in\\[0.3 cm]
		{\large {\textbf{Computer Science and Engineering}}}\\[0.3 cm]
		by\\[0.3 cm]
		{\Large {\textbf{\@author}}}\\[0.3 cm]
		{ {\textit {Under the supervision of}}}\\[0.3 cm]
		{\large {\textbf{\tbox}}}\\[0.3 cm]
		\includegraphics[trim={0 25cm 16.7cm 0}, clip, scale=0.8]{iitg_logo.pdf}
		\hrule
		\vspace{10 pt}
		{ {\textbf{ Department of Computer Science and Engineering}}} \\[0.3 cm]
		{ {\textbf{ Indian Institute of Technology Guwahati}}} \\[0.3 cm]
		{ {\textbf{ Guwahati - 781039 Assam India}}} \\[0.3 cm]
		{ {\textbf{ \textsc{\@submissionMonth},~\@submissionYear}}} \\[0.3 cm]
    \end{center}
  \end{titlepage}
}

% generate copyright text 
\newcommand{\copyrightText}{
	Copyright \copyright~\@author~\@submissionYear. All Rights Reserved.
	\pagenumbering{roman}
	\setcounter{page}{2}
	\clearpage
}

% generate dedication page
\newcommand {\dedication}[1] {
	%\topskip 0pt
	% removed topskip as it caused problems with cleardoublepage
	% the page looks 'almost' the same as before
	\vspace*{\fill}
		{#1}
	\vspace*{\fill}
	\cleardoublepage
}

% generate acknowledgements page
\newcommand {\acknowledgements}[1] {
	\phantomsection
	\begin{center}
		{\Huge {\textbf {Acknowledgements}}}
	\end{center}
	\hrule
	\vspace{1 in}
	{#1} \\[0.6 in]
	\begin{flushright}
	\@certdate \hfill \@author 

	\end{flushright}
	%\addcontentsline{toc}{chapter}{\numberline{}Acknowledgements}
	\cleardoublepage
}

% generate declaration Page
\newcommand {\declaration} {
	\begin{center}
		{\Huge {\textbf {Declaration}}}
	\end{center}
	\hrule
	\vspace {1 in}
	I certify that 
	\begin{itemize}
		\item The work contained in this thesis is original and has been done by myself and under the general supervision of my supervisor(s).
		\item The work reported herein has not been submitted to any other Institute for any degree or diploma.
		\item Whenever I have used materials (concepts, ideas, text, expressions, data, graphs, diagrams, theoretical analysis, results, etc.) from other sources, I have given due credit by citing them in the text of the thesis and giving their details in the references. Elaborate sentences used verbatim from published work have been clearly identified and quoted.
		\item I also aff{i}rm that no part of this thesis can be considered plagiarism to the best of my knowledge and understanding and take complete responsibility if any complaint arises.
		\item I am fully aware that my thesis supervisor(s) are not in a position to check for any possible instance of plagiarism within this submitted work.
	\end{itemize}
	\vspace{1 in}
	\@certdate \hfill \@author 
	\cleardoublepage
}


% generate certificate Page
\newcommand {\certificate} {
	\begin{minipage}{.2\textwidth}
        \centering
	\includegraphics[trim={0 25cm 16.7cm 0}, clip, scale=0.6]{iitg_logo.pdf}
    	\end{minipage}%
	\begin{minipage}{.8\textwidth}
		\vspace{15pt}
        \begin{tabular}{ l }
		{\large Department of Computer Science and Engineering} \\
		{\large Indian Institute of Technology Guwahati} \\
		{\large Guwahati - 781039 Assam India} \\
	\end{tabular}\\[1 pt]
	\end{minipage}%
	\vspace{1 pt}
	\hrule
	\vspace{5 pt}
	\certhdr 
	\begin{center}
		{\Huge {\textbf {\underline{Certif{i}cate}}}}\\[0.5 cm]
	\end{center}
	This is to certify that this thesis entitled ``\textbf {\@title}" submitted by {\textbf \@author} in the partial fulfilment of the requirements for the award of the Degree of Philosophy, to the Indian Institute of Technology Guwahati, Assam, India, is a record of the bonaf{i}de research work carried out by the candidate under my guidance and supervision at the Department of Computer Science and Engineering, Indian Institute of Technology Guwahati, Assam, India, and, to the best of my knowledge, no part of the work reported in this thesis has been presented for the award of any degree at any other institution and thus is worthy of consideration for the award of the degree of Doctor of Philosophy of the Institute.\\
	
	Date: \@certdate \\
	Place: Guwahati\\ [1 in]
	\cbox
	\cleardoublepage
}


%Publications based on the thesis
\newcommand {\publications}[1] {
	\begin{center}
		{\huge {\textbf {Publications}}}
	\end{center}
	\hrule
	\vspace {1 cm}
	#1
	\cleardoublepage
	% save the page counter value
	% needed to continue page number in abstract section
	\setcounter{savepage}{\value{page}}
}

% custom abstract heading
\renewcommand{\abstractname}{
	{\Huge Abstract} \\[0.5 in]	
	\addcontentsline{toc}{chapter}{\numberline{}Abstract}
	% set the saved page counter value
	% now page numbering will continue instead of resetting
	% after abstract
	\setcounter{page}{\value{savepage}}
	% this forces the page number to be displayed on abstract page
	\thispagestyle{plain}
}

% to change header of chapters
\renewcommand\chaptername{}

% change the headings to align right and change the size of chapter number
\newcommand*{\justifyheading}{\raggedleft}
\titleformat{\chapter}[display]
  {\huge\bfseries\justifyheading\color{black}}
  {{\chaptertitlename}{{\fontsize{50}{40}\selectfont{\thechapter}}}}
  {2pt}
  {\huge} 
  [\titlerule]

\titlespacing{\chapter}{0pt}{50pt}{2\baselineskip}

% generate vita or bio of author
\newcommand {\vita}[3] {
	\phantomsection
	\thispagestyle{empty}
	\begin{center}
		{\huge \textbf{{Vitae}}}
	\end{center}
	
	% wrap figure begin
	\begin{wrapfigure}{L}{0.3\textwidth}
		\centering
		\includegraphics[width=0.25\textwidth]{./vitae/batman.jpg}
		%\caption{\label{fig:frog1}This is a figure caption.}
	\end{wrapfigure}
	% wrap figure end
	
	\hrule
	\vspace{20pt}
	{#1}
	\vspace{0.3 in}
	{\Large {\textbf{Author Contact Information}}}\\[0.2 in]
	{#3}
	\addcontentsline{toc}{chapter}{\numberline{}Vitae}
	\cleardoublepage
}

