import System.Directory
import System.FilePath
import System.Environment

data Paths = Paths {source :: FilePath, target :: FilePath}

args :: IO Paths
args = do
    input <- getArgs
    source <- makeAbsolute (input!!0)
    target <- makeAbsolute (input!!1)
    return $ Paths source target

main :: IO ()
main = do
    paths <- args

    sourceFiles <- getFiles $ source paths
    targetFiles <- getFiles $ target paths

    let newFiles = getDiff sourceFiles targetFiles
    let oldFiles = getDiff targetFiles sourceFiles

    putStrLn "Files to be copied:"
    printFiles newFiles
    putStrLn "Files to be removed:"
    printFiles oldFiles

    putStrLn "continue? y/n"
    answer <- getLine
    if answer /= "y" then
        return ()
    else do
        copyFiles newFiles paths
        removeFiles oldFiles (target paths)

printFiles :: [FilePath] -> IO ()
printFiles [] = return ()
printFiles (x:xs) = do
    putStrLn ("- " <> x)
    printFiles xs

-- call getFilesRecursive for the first time and remove trailing filepath ("")
getFiles :: FilePath -> IO [FilePath]
getFiles s = do
    files <- getFilesRecursive s ""
    return (init files)

-- return relative paths of all files inside a path
-- recursive items appear before parents
getFilesRecursive :: FilePath -> FilePath -> IO [FilePath]
getFilesRecursive prefix relativePath = do
    let fullPath = prefix </> relativePath
    isDir <- doesDirectoryExist fullPath

    if isDir then do
        innerFiles <- listDirectory fullPath
        contents <- concatMapM (getFilesRecursive prefix . (relativePath </>)) innerFiles

        -- directories are added after its contents
        -- (the order is important)
        return (contents ++ [relativePath])
    else
        return [relativePath]

-- get files that exists in (first arg) but don't in (second arg)
getDiff :: [FilePath] -> [FilePath] -> [FilePath]
getDiff [] _ = []
getDiff (x:xs) files
    | x `elem` files = rest
    | otherwise = x : rest
    where rest = getDiff xs files

copyFiles :: [FilePath] -> Paths -> IO ()
copyFiles [] _ = return ()
copyFiles (x:xs) paths@(Paths source target) = do
    -- directories are last in the list
    -- therefore the last items must be copied first
    copyFiles xs paths
    copyTarget (source </> x) (target </> x)

copyTarget :: FilePath -> FilePath -> IO ()
copyTarget source target = do
    isDir <- doesDirectoryExist source
    if isDir then
        createDirectory target
    else
        copyFile source target

removeFiles :: [FilePath] -> FilePath -> IO ()
removeFiles [] _ = return ()
removeFiles (x:xs) target = do
    -- directories are last in the list and must be removed last
    -- therefore the list is removed in order
    removeTarget (target </> x)
    removeFiles xs target

removeTarget :: FilePath -> IO ()
removeTarget target = do
    isDir <- doesDirectoryExist target
    if isDir then
        removeDirectory target
    else
        removeFile target

concatMapM :: Monad m => (a -> m [b]) -> [a] -> m [b]
concatMapM op = foldr f (return [])
    where f x xs = do x <- op x; if null x then xs else do xs <- xs; return $ x++xs
