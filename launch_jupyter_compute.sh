# Compute node
LOG=~/sunpyter_log.txt
rm -r $LOG
touch $LOG
chmod go-r $LOG
# If you need to use GPU, specify --partition as accel_ai and include --gres=gpu:n (n is number of GPUs)
sbatch --partition accel_ai -A SEDACCOUNT -o $LOG -J SUNPYTER_$USER --dependency=singleton -n 1 --gres=gpu:1 --oversubscribe jupyter notebook --no-browser --ip='*'
tail -f $LOG
