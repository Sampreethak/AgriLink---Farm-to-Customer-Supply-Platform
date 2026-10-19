% -------------------------------------------------------------------
%  @LaTeX-class-file{
%     filename        = "idp_report.cls",
%     author          = "Saroj S Shivagunde, SoET, VU",
%     advisors        = "Mahendra B M, Subrahmanya K N",
%     version         = "1.0",
%     date            = "18-Aug-2026",
%     codetable       = "ISO/ASCII",
%     keywords        = "LaTeX, pdfLaTeX, idp_report_vu",
%     docstring       = "A report document class for Vidyashilp University Inter-Disciplinary Project Report. (pdfLaTeX version)"
% --------------------------------------------------------------------

% process using the LaTeX2e format
\NeedsTeXFormat{LaTeX2e}

% provides the following class to users
\ProvidesClass{idp_report}[18/08/2026 custom report document class for Vidyashilp University Inter-Disciplinary Project Report]

% twoside, openright to start new chapters from odd numbered pages
\LoadClass[twoside,openright,11pt]{report}

% for setting up margins
\RequirePackage[left=1in,right=1in,top=1in,bottom=1in]{geometry}

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

% to clear page numbers from empty pages
\RequirePackage{emptypage}

% for fancy headers at the top of the pages
\RequirePackage{fancyhdr}

% for list of symbols
%\RequirePackage{nomencl}

% for algorithms and list of algorithms
\RequirePackage{algorithm}

% for fancy font for the name of degree
\RequirePackage{yfonts}

% remove the ugly red boxes around the hyperlinks & gives them nice colors
\RequirePackage{xcolor}
\hypersetup{
    colorlinks,
    linkcolor={red!50!black},
    citecolor={blue!50!black},
    urlcolor={blue!80!black}
}
%\hypersetup{
%    colorlinks,
%    linkcolor={black!50!black},
%    citecolor={black!50!black},
%    urlcolor={black!80!black}
%}

%For style font for Certificate
\RequirePackage{yfonts}

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

%\onehalfspacing

%\doublespacing

% new command for submission month and year
\newcommand{\submissionMonth}[1]{\gdef\@submissionMonth{#1}}
\newcommand{\submissionYear}[1]{\gdef\@submissionYear{#1}}
\newcommand{\program}[1]{\def\@program{#1}}
\def\@program{Data Science}
\newcommand{\UEN}[1]{\def\@UEN{#1}}
\def\@UEN{}

% =========================================================
% Multi-author support (up to three authors)
% =========================================================
\newcommand{\@authortwo}{}
\newcommand{\@authorthree}{}
\newcommand{\@UENtwo}{}
\newcommand{\@UENthree}{}
\newif\ifauthortwo
\newif\ifauthorthree
\authortwofalse
\authorthreefalse

\newcommand{\authorTwo}[1]{\gdef\@authortwo{#1}\authortwotrue}
\newcommand{\authorThree}[1]{\gdef\@authorthree{#1}\authorthreetrue}
\newcommand{\UENTwo}[1]{\gdef\@UENtwo{#1}}
\newcommand{\UENThree}[1]{\gdef\@UENthree{#1}}

% Helper: render all authors for the title page
\newcommand{\authorsblock}{%
  \ifauthortwo
    \ifauthorthree
      % Three authors side by side
      \begin{tabular}{ccc}
        {\Large\textbf{\@author}} & {\Large\textbf{\@authortwo}} & {\Large\textbf{\@authorthree}} \\
        {\normalsize\@UEN} & {\normalsize\@UENtwo} & {\normalsize\@UENthree}
      \end{tabular}
    \else
      % Two authors side by side
      \begin{tabular}{cc}
        {\Large\textbf{\@author}} & {\Large\textbf{\@authortwo}} \\
        {\normalsize\@UEN} & {\normalsize\@UENtwo}
      \end{tabular}
    \fi
  \else
    % Single author
    {\Large\textbf{\@author}} \\
    {\normalsize\@UEN}
  \fi
}

% Helper: all author names and UENs for certificate/declaration
\newcommand{\allauthornames}{%
  \@author\ (\@UEN)%
  \ifauthortwo, \@authortwo\ (\@UENtwo)\fi%
  \ifauthorthree, and \@authorthree\ (\@UENthree)\fi%
}

% Helper: author+UEN table for signatures
\newcommand{\authorsigblock}{%
  \ifauthortwo
    \ifauthorthree
      \begin{tabular}{p{0.3\textwidth}p{0.3\textwidth}p{0.3\textwidth}}
        \makebox[2in]{\hrulefill} & \makebox[2in]{\hrulefill} & \makebox[2in]{\hrulefill} \\
        \@author & \@authortwo & \@authorthree \\
        \@UEN & \@UENtwo & \@UENthree
      \end{tabular}
    \else
      \begin{tabular}{p{0.45\textwidth}p{0.45\textwidth}}
        \makebox[2.5in]{\hrulefill} & \makebox[2.5in]{\hrulefill} \\
        \@author & \@authortwo \\
        \@UEN & \@UENtwo
      \end{tabular}
    \fi
  \else
    \makebox[2.5in]{\hrulefill} \\
    \@author \\
    \@UEN
  \fi
}

% for supervisor names on front page
% manages for one and two supervisor names accordingly
\newcommand{\supervisor}[2][]{%
    \ifthenelse{\isempty{#1}}
            {\newcommand{\cbox}{\makebox[2.5in]{\hrulefill} \\ #2 \\(Project Guide)} \newcommand{\tbox}{#2}}
            % if no title option given
            {\newcommand{\cbox}{\makebox[2.5in]{\hrulefill} \hfill \makebox[2.5in]{\hrulefill} \\ #1  \hfill  #2} \newcommand{\tbox}{#2\\#1}
            } % if author has 2 supervisors
}

%% supervisor profile for certificate page
%\newcommand{\supervisorprofile}[2][]{
%    \ifthenelse{\isempty{\noindent#1}}
%	{\newcommand{\certhdr}{\noindent#2}} % if only one supervisor
%	{\newcommand{\certhdr}{	\begin{minipage}{.50\textwidth}{\large {#2}}\end{minipage}%
%				\begin{minipage}{.50\textwidth}
%					\begin{flushright}
%						{\large{#1}}										
%					\end{flushright}
%				\end{minipage}%
%			}
%		}
%}

% =========================================================
% Supervisor information
% =========================================================

\newif\ifsupervisortwo
\supervisortwofalse

\newcommand{\@supervisoronename}{}
\newcommand{\@supervisoronedesignation}{}
\newcommand{\@supervisoroneemail}{}

\newcommand{\@supervisortwoname}{}
\newcommand{\@supervisortwodesignation}{}
\newcommand{\@supervisortwoemail}{}

% ---------------------------------------------------------
% First supervisor
% ---------------------------------------------------------

\newcommand{\supervisorone}[3]{%
    \gdef\@supervisoronename{#1}%
    \gdef\@supervisoronedesignation{#2}%
    \gdef\@supervisoroneemail{#3}%
}

% ---------------------------------------------------------
% Second supervisor
% ---------------------------------------------------------

\newcommand{\supervisortwo}[3]{%
    \supervisortwotrue
    \gdef\@supervisortwoname{#1}%
    \gdef\@supervisortwodesignation{#2}%
    \gdef\@supervisortwoemail{#3}%
}

% =========================================================
% Head of Department
% =========================================================

\newif\ifhod
\hodfalse
\newcommand{\@hodname}{}
\newcommand{\@hoddesignation}{}
\newcommand{\@hodemail}{}

\newcommand{\hod}[3]{%
    \hodtrue
    \gdef\@hodname{#1}%
    \gdef\@hoddesignation{#2}%
    \gdef\@hodemail{#3}%
}

% =========================================================
% Title page supervisor information
% =========================================================

\newcommand{\tbox}{%
    \ifsupervisortwo
        \begin{minipage}{.45\textwidth}
            \textbf{\@supervisoronename}\par
            \@supervisoronedesignation
        \end{minipage}%
        \begin{minipage}{.45\textwidth}
            \begin{flushright}
                \textbf{\@supervisortwoname}\par
                \@supervisortwodesignation
            \end{flushright}
        \end{minipage}%
    \else
        \textbf{\@supervisoronename}\par
        \@supervisoronedesignation
    \fi
}

% =========================================================
% Certificate supervisor information
% =========================================================

\newcommand{\certhdr}{%
    \ifsupervisortwo
        \noindent
        \begin{minipage}{.50\textwidth}
            {\large \textbf{\@supervisoronename}}\par
            {\large \@supervisoronedesignation}\par
            {\large Email: \@supervisoroneemail}
        \end{minipage}%
        \begin{minipage}{.50\textwidth}
            \begin{flushright}
                {\large \textbf{\@supervisortwoname}}\par
                {\large \@supervisortwodesignation}\par
                {\large Email: \@supervisortwoemail}
            \end{flushright}
        \end{minipage}%
        \ifhod
            \vspace{8pt}\par
            \noindent
            \begin{minipage}{\textwidth}
                {\large \textbf{\@hodname}}\par
                {\large \@hoddesignation}\par
                {\large Email: \@hodemail}
            \end{minipage}%
        \fi
    \else
        \noindent
        \begin{minipage}{\textwidth}
            {\large \textbf{\@supervisoronename}}\par
            {\large \@supervisoronedesignation}\par
            {\large Email: \@supervisoroneemail}
        \end{minipage}%
    \fi
}

% =========================================================
% Certificate signature boxes
% =========================================================

\newcommand{\cbox}{%
    \ifsupervisortwo
        \ifhod
            % Three signature columns: Guide 1 | Guide 2 | HOD
            \begin{tabular}{p{0.3\textwidth}p{0.3\textwidth}p{0.3\textwidth}}
                \makebox[1.8in]{\hrulefill} & \makebox[1.8in]{\hrulefill} & \makebox[1.8in]{\hrulefill} \\
                {\small\textbf{\@supervisoronename}} & {\small\textbf{\@supervisortwoname}} & {\small\textbf{\@hodname}} \\
                {\small(Project Guide)} & {\small(Project Guide)} & {\small(Head of Department)}
            \end{tabular}
        \else
            \begin{center}
                \makebox[2.5in]{\hrulefill}
                \hfill
                \makebox[2.5in]{\hrulefill}
                
                \@supervisoronename
                \hfill
                \@supervisortwoname
                
                (Project Guide)
                \hfill
                (Project Guide)
            \end{center}
        \fi
    \else
        \begin{flushleft}
            \makebox[2.5in]{\hrulefill}
            
            \@supervisoronename
            
            (Project Guide)
        \end{flushleft}
    \fi
}





% holds the date for certificate page & acknowledgements page
\newcommand{\certdate}[1]{\gdef\@certdate{#1}}

% correct the \cleardoublepage behaviour
% incomplete
\renewcommand{\cleardoublepage}{
  \clearpage
%  \ifodd\value{page}\hbox{}\clearpage\fi
}

% title page
% renew the maketitle command to make custom title page
\renewcommand{\maketitle}{%
  \begin{titlepage}
    %\vspace*{0.1in}
 	   \begin{center}
		\begin{spacing}{2.5}
			{\Huge {\textbf {\@title}}}\\[0.6 in]
		\end{spacing}
		
		{\large {\textit {Report submitted in partial fulfilment of the requirements \\ for the award of the degree of}}}\\[0.3 in]
		\includegraphics[scale=0.3]{btech_text.pdf}\\[0.2 in]
		%{\Huge {\usefont{U}{ygoth}{m}{n} Bachelor of Technology (Hons.)}} \\[0.2 in]		
		in\\[0.2 in]
		{\large {\textbf{\@program}}}\\[0.4 in]
		by\\[0.2 in]
		\authorsblock\\[0.4 in]
		{\large {\textit {Under the supervision of}}}\\[0.2 in]
		{\large {\textbf{\tbox}}}\\[0.4 in]
		{\large {\textbf{{\color{black} Course Name: Interdisciplinary Project}}}}\\ % 
        {\large {\textbf{Course Code: DATA802}}}\\[0.1 in] % 
        \includegraphics[scale=0.5]{vu_logo.pdf}
		\vspace{15 pt}
		\hrule
		\vspace{15 pt}
		{\small {\textbf{ School of Engineering and Technology}}} \\[0.1 in]
		{\small {\textbf{ Vidyashilp University}}} \\[0.1 in]
		{\small {\textbf{ \#125, Bettanahalli, Kundana Hobli, Chapparkallu Road, Bangalore-562110}}} \\[0.1 in]
		{\large {\textbf{ \textsc{\@submissionMonth},~\@submissionYear}}} \\[0.1 in]
    \end{center}
  \end{titlepage}
}

%% generate copyright text 
%\newcommand{\copyrightText}{
%		\pagenumbering{roman}
%	Copyright \copyright~\@author~\@submissionYear. All Rights Reserved.
%	\setcounter{page}{2}
%	\pagestyle{empty}
%	\clearpage
%}

% generate dedication page
\newcommand {\dedication}[1] {
	%\topskip 0pt
	% removed topskip as it caused problems with cleardoublepage
	% the page looks 'almost' the same as before
	\vspace*{\fill}
		{#1}
	\vspace*{\fill}
	%\thispagestyle{empty}
%	\cleardoublepage
\clearpage
}

% generate acknowledgements page
\newcommand {\acknowledgements}[1] {
	\phantomsection
	\begin{center}
		{\Huge {\textbf {Acknowledgements}}}
	\end{center}
	\hrule
	\vspace{0.4 in}
	{#1} \\[0.4 in]
	\@certdate
	\vspace{0.5 in}

	\authorsigblock
	%\addcontentsline{toc}{chapter}{\numberline{}Acknowledgements}
%	\thispagestyle{empty}
	\cleardoublepage
}

% generate declaration Page
\newcommand {\declaration} {
	\begin{center}
		{\Huge {\textbf {Declaration}}}
	\end{center}
	\hrule
	\vspace {1 in}
	We certify that 
	\begin{itemize}
		\item The work contained in this report is original and has been done by us under the general supervision of our project guide.
		\item The work reported herein has not been submitted to any other Institute for any degree or diploma.
		\item Whenever we have used materials (concepts, ideas, text, expressions, data, graphs, diagrams, theoretical analysis, results, etc.) from other sources, we have given due credit by citing them in the text of the report and giving their details in the references. Elaborate sentences used verbatim from published work have been clearly identified and quoted.
		\item We also aff{i}rm that no part of this report can be considered plagiarism to the best of our knowledge and understanding and take complete responsibility if any complaint arises.
	\end{itemize}
	\vspace{0.5 in}
	\@certdate
	\vspace{0.5 in}

	\authorsigblock
%	\thispagestyle{empty}
	\clearpage
}


% generate certificate Page
\newcommand {\certificate} {
	\begin{minipage}{.2\textwidth}\hspace*{-1cm}
	\includegraphics[scale=0.3]{vu_logo.pdf}
    	\end{minipage}%
	\begin{minipage}{.8\textwidth}
		\vspace{15pt}
        \begin{tabular}{ l }
		{\large School of Engineering and Technology} \\
		{\large Vidyashilp University} \\
		{\large Bangalore - 562110, Karnataka, India} \\
	\end{tabular}\\[5pt]
	\end{minipage}%
	\vspace{5 pt}
	\hrule
	\vspace{10 pt}
	\certhdr
	
	
	\vspace{0.6 in}
	\begin{center}
		{\Huge {\textbf {\underline{\textswab{Certif{i}cate}}}}}\\[0.5 in]
	\end{center}
	This is to certify that this report entitled ``\textbf {\normalsize{\@title}}'' submitted by {\textbf{\allauthornames}}, for the \textit{Interdisciplinary Project (DATA802)} in partial fulfilment of the requirements for the award of the degree of Bachelor of Technology (Hons.) in {\@program}, to the Vidyashilp University, Bangalore, Karnataka, India, is a record of the bonaf{i}de work carried out by these students under my/our guidance and supervision at the School of Engineering and Technology, Vidyashilp University, Bangalore, Karnataka, India. To the best of my/our knowledge, no part of the work reported in this report has been presented for the award of any degree at any other institution.\\
	
	\noindent Date: \@certdate \\
	Place: Bangalore\\ [1 in]
	\cbox
%	\thispagestyle{empty}
	\cleardoublepage
		\setcounter{savepage}{\value{page}}
	%	\pagestyle{plain}
}



% custom abstract heading
\renewcommand{\abstractname}{
		\setcounter{page}{\value{savepage}}
		% this forces the page number to be displayed on abstract page
		%\thispagestyle{plain}
		
	{\Huge Abstract} \\[0.5 in]	
	\addcontentsline{toc}{chapter}{\numberline{}Abstract}
\
	%\pagestyle{plain}
}



%\let\oldpage\thepage
%\renewcommand{\thepage}{
%\ifnum \value{chapter} = 1
%%\pagenumbering{arabic}
%%\setcounter{page}{1}
%S-\arabic{page}
%%\else
%%\oldpage
%\fi
%}



% to change header of chapters
\renewcommand\chaptername{}

% change the headings to align right and change the size of chapter number
\newcommand*{\justifyheading}{\raggedleft}
\titleformat{\chapter}[display]
  {\huge\bfseries\justifyheading\color{black}}
  {{\chaptertitlename}{{\fontsize{100}{80}\selectfont{\thechapter}\ifnum \value{chapter} = 1
  \pagenumbering{arabic}
  \fi}}}
  {5pt}
  {\huge}
  [\titlerule]




\titlespacing{\chapter}{0pt}{50pt}{1\baselineskip}

%\newcommand{\photo}[1]{	\begin{wrapfigure}{L}{0.3\textwidth}
%							\centering
%							\includegraphics[width=0.25\textwidth]{#1}
%						%	\caption*{\textbf\@author}
%						\end{wrapfigure}}


%Appendix
\renewcommand{\appendix}[1] {
\addcontentsline{toc}{chapter}{\numberline{}Appendix}
	\phantomsection
	\pagestyle{plain}
	\begin{flushright}
		{\huge {\textbf {Appendix}}}
	\end{flushright}
	\hrule
	\vspace{0.5cm}
	#1
	\cleardoublepage
	
}


%Publications based on the thesis
\newcommand {\publications}[1] {
\addcontentsline{toc}{chapter}{\numberline{}Publications}
	\phantomsection
	\pagestyle{plain}
	\begin{flushright}
		{\huge {\textbf {Publications}}}
	\end{flushright}
	\hrule
	\vspace{0.5cm}
	#1
	\cleardoublepage
		
}






