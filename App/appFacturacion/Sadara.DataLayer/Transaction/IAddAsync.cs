﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Sadara.DataLayer.Transaction
{

    public interface IAddAsync<T>
    {

        Task<T> AddAsync(T entity);

    }

}
