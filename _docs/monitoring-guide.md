# Advanced System Monitoring Tools for WSL2 and Windows

## Best Tools for WSL2 Monitoring

### 1. Glances (Terminal-based, Comprehensive)
```bash
pip install glances
glances
```
- **Features**: Real-time memory, CPU, disk, network usage
- **Colors**: Red = critical, Yellow = warning, Green = normal
- **WSL2 Specifics**: Shows container, process, and system metrics

### 2. Htop (Enhanced Top)
```bash
# Install (if sudo becomes available)
sudo apt install -y htop
htop
```
- **Features**: Interactive process viewer with tree view, colors, and sorting
- **Key Shortcuts**: F5 (tree), F6 (sort), F9 (kill)

### 3. Atop (Advanced System & Process Monitor)
```bash
sudo apt install -y atop
atop
```
- **Features**: Historical data, per-process resource usage, disk IO
- **Useful**: Press 'd' for disk details, 'n' for network, 'm' for memory

## Windows Monitoring Tools (Better than Task Manager)

### 1. Process Explorer (Sysinternals)
- **Download**: https://learn.microsoft.com/en-us/sysinternals/downloads/process-explorer
- **Features**:
  - Tree view of processes
  - Detailed memory and CPU breakdown per process
  - Handle and DLL viewing
  - Find which process is using a file

### 2. Process Monitor (Sysinternals)
- **Download**: https://learn.microsoft.com/en-us/sysinternals/downloads/procmon
- **Features**: Real-time file system, registry, and process/thread activity
- **Great for debugging**: Find what's causing disk/CPU spikes

### 3. Resource Monitor (Built-in)
- **Open**: Win + R → `resmon`
- **Features**:
  - Detailed memory analysis (Committed, Cached, Available)
  - Disk and Network IO per process
  - CPU usage by process and service

### 4. Performance Monitor (Built-in)
- **Open**: Win + R → `perfmon`
- **Features**: Customizable data collectors, real-time graphs
- **Create Data Collector Set**: Right-click "User Defined" → New
- **Add Counters**: Memory, Processor, Disk, Network

### 5. WSL2 Specific Tools

#### WSL2 Process Monitor (Windows)
- **Get Process IDs**:
  ```cmd
  wsl --list --running
  wsl --exec ps aux
  ```
- **Kill Process from Windows**:
  ```cmd
  taskkill /PID <PID> /F
  ```

#### Check WSL2 Memory from Windows
```powershell
Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object TotalVisibleMemorySize, FreePhysicalMemory
Get-Process -Name 'vmmem'
```

## Recommended Monitoring Setup

### For WSL2 Development
1. Open **Glances** in WSL2 terminal:
   ```bash
   glances
   ```

2. Open **Process Explorer** on Windows

3. Use **Resource Monitor** to watch memory and disk IO

### Key Metrics to Watch
- **WSL2 Memory**: Should stay under 24GB limit
- **Vmmem Process**: Windows process that manages WSL2 memory
- **Docker Desktop**: Uses additional resources if containers are running

## Troubleshooting High Memory Usage

If you see high memory usage:
1. Check which WSL2 processes are using memory:
   ```bash
   ps aux --sort=-%mem
   ```

2. Check Docker container memory usage:
   ```bash
   docker stats
   ```

3. Clear WSL2 memory cache:
   ```bash
   sudo sh -c 'echo 1 > /proc/sys/vm/drop_caches'
   ```

4. Restart WSL2 from Windows:
   ```cmd
   wsl --shutdown
   ```
