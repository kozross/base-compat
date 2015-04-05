#if !MIN_VERSION_base(4,8,0)
{-# LANGUAGE ForeignFunctionInterface #-}
#endif
module Foreign.Marshal.Alloc.Compat (
  module Base
, calloc
, callocBytes
) where
import Foreign.Marshal.Alloc as Base

#if !MIN_VERSION_base(4,8,0)
import GHC.IO.Exception

-- |Like 'malloc' but memory is filled with bytes of value zero.
--
{-# INLINE calloc #-}
calloc :: Storable a => IO (Ptr a)
calloc = doCalloc undefined
  where
    doCalloc       :: Storable b => b -> IO (Ptr b)
    doCalloc dummy = callocBytes (sizeOf dummy)

-- |Llike 'mallocBytes' but memory is filled with bytes of value zero.
--
callocBytes :: Int -> IO (Ptr a)
callocBytes size = failWhenNULL "calloc" $ _calloc 1 (fromIntegral size)

-- asserts that the pointer returned from the action in the second argument is
-- non-null
--
failWhenNULL :: String -> IO (Ptr a) -> IO (Ptr a)
failWhenNULL name f = do
   addr <- f
   if addr == nullPtr
      then ioError (IOError Nothing ResourceExhausted name 
                                        "out of memory" Nothing Nothing)
      else return addr

foreign import ccall unsafe "stdlib.h calloc"  _calloc  :: CSize -> CSize -> IO (Ptr a)
#endif