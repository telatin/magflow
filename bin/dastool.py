#!/usr/bin/env python
"""
A wrapper to run DAS Tool given a set of binning outputs
August 2022, Andrea Telatin
"""

import os, sys
import argparse
import subprocess
def remove_by_patterns(path, patterns):
    """
    Remove files in a directory  containing patterns
    """
    for file in os.listdir(path):
        for pattern in patterns:
            if pattern in file:
                print("Removing " + file, file=sys.stderr)
                os.remove(os.path.join(path, file))
                break

def files_by_pattern(path, keyword, extension):
    """
    Return a list of files in a directory  containing keyword and ending by extension
    """
    files = []
    for file in os.listdir(path):
        if keyword in file and file.endswith(extension):
            files.append(file)
    return files

    
if __name__ == "__main__":
    args = argparse.ArgumentParser()
    args.add_argument("-i", "--input", help="Input directory", required=True)
    args.add_argument("-o", "--output", help="Output directory [default: %(default)s]", default="refine")
    args.add_argument("-c", "--contigs", help="Contigs file", required=True)
    args.add_argument("-t", "--threads", help="Number of threads", default=1, type=int)
    args.add_argument("--plots"   , help="Create plots", action="store_true")
    args.add_argument("--verbose"   , help="Verbose output", action="store_true")
    args = args.parse_args()

    if not os.path.exists(args.input):
        print("Error: Input directory not found: " + args.input)
        sys.exit(1)

    if not os.path.exists(args.contigs):
        print("Error: Contigs file not found: " + args.contigs)
        sys.exit(1)

    if not os.path.exists(args.output):
        if args.verbose:
            print("Creating output directory: " + args.output)
        os.mkdir(args.output)
    
    remove_by_patterns(args.input, ['unbinned.fa', 'tooShort.fa', 'lowDepth.fa'])

    binning_tools = {
        'metabat': {
            'contains': 'metabat',
            'extension': '.fa',
            'files': []
        },
        'maxbin2': {
            'contains': "maxbin",
            'extension': ".fasta",
            'files': []
        },
        'metadecoder':{
            'contains': "metadec",
            'extension': ".fasta",
            'files': []
        }
    }

    labels = []
    tsv_files = []
    for tool in binning_tools:
        meta = binning_tools[tool]
        files = files_by_pattern(args.input, meta["contains"], meta["extension"])
        binning_tools[tool]["files"] = files
        if len(files) > 0:
            dir = os.path.join(args.output, tool)
            os.mkdir(dir) if not os.path.exists(dir) else None
            for file in files:
                if args.verbose:
                    print("Symling " + file + " to " + os.path.join(dir, file))
                os.symlink(os.path.join(args.input, file), os.path.join(dir, file))
            labels.append(tool)
            outfile = os.path.join(dir, "{}.tsv".format(tool))
            tsv_files.append(os.path.abspath(outfile))

           
            cmd = ["Fasta_to_Contig2Bin.sh",  "--input_folder", dir, "--extension", meta["extension"]]
            # Run cmd and save output to outfile
            subprocess.Popen(cmd, stdout=open(outfile, "w")).wait()
            if args.verbose:
                print("[{}]:".format(tool)," ".join(cmd), file=sys.stderr)
    
    
    
    labels_str = ",".join(labels)
    tsv_files_str = ",".join(tsv_files)
    
    dascommand = ["DAS_Tool", "-l", labels_str, "-i", tsv_files_str, 
        "-c", args.contigs, 
        "-o", args.output, 
        "--search_engine", "diamond", 
        "-t", str(args.threads), 
        "--write_bins"]
    
    if args.plots:
        dascommand.append("--create_plots").append("1")
    
    if args.verbose:
        print("DASTOOL:"," ".join(dascommand), file=sys.stderr)
    # Execute dascommand
    
    process = subprocess.Popen(dascommand,
                     stdout=subprocess.PIPE, 
                     stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    
    if args.verbose or process.returncode != 0:
        print("----------------------------------------------------", file=sys.stderr)
        print(stdout.decode("utf-8"), file=sys.stderr)
        print("----------------------------------------------------", file=sys.stderr)
        print(stderr.decode("utf-8"), file=sys.stderr)

    if process.returncode != 0:
        print("Error: DAS Tool failed", file=sys.stderr)
        sys.exit(1)